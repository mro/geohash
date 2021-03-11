(*
 * calc.ml
 *
 * Created by Marcus Rohrmoser on 11.03.21.
 * Copyright © 2021-2021 Marcus Rohrmoser mobile Software http://mro.name/~me. All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *)

(* Inspired by https://github.com/mmcloughlin/geohash/blob/master/geohash.go *)

(* https://github.com/mmcloughlin/deconstructedgeohash/blob/master/geohash.go#L23 *)
let quantize (lat, lng) =
  ( Float.ldexp ((lat +. 90.0) /. 180.0) 32,
    Float.ldexp ((lng +. 180.0) /. 360.0) 32 )

(* https://github.com/mmcloughlin/deconstructedgeohash/blob/master/geohash.go#L33 *)
let spread x =
  let f s m x' =
    m |> Int64.logand (x' |> Int64.logor (Int64.shift_left x' s))
  in
  x |> f 16 0x0000ffff0000ffffL |> f 8 0x00ff00ff00ff00ffL
  |> f 4 0x0f0f0f0f0f0f0f0fL |> f 2 0x3333333333333333L
  |> f 1 0x5555555555555555L

(* https://github.com/mmcloughlin/deconstructedgeohash/blob/master/geohash.go#L45 *)
let interleave (x, y) = spread x |> Int64.logor (Int64.shift_left (spread y) 1)

let base32_encode chars x =
  let alpha = "0123456789bcdefghjkmnpqrstuvwxyz" in
  let rec f i x' b =
    match i with
    | -1 -> b
    | _ ->
        Bytes.set b i alpha.[x' |> Int64.logand 0x1fL |> Int64.to_int];
        f (i - 1) (Int64.shift_right x' 5) b
  in
  Bytes.create chars |> f (chars - 1) x |> Bytes.to_string

let encode chars (lat, lng) =
  let la, lo = quantize (lat, lng) in
  Ok
    (Int64.shift_right ((Int64.of_float la, Int64.of_float lo) |> interleave) 4
    |> base32_encode chars)

let base32_decode hash =
  let len = String.length hash in
  let rec f idx x =
    match len - idx with
    | 0 -> Ok x
    | _ -> (
        match hash.[idx] |> Iter.P.b32_int_of_char with
        | Error e -> Error e
        | Ok v ->
            f (idx + 1) (v |> Int64.of_int |> Int64.logor (Int64.shift_left x 5))
        )
  in
  f 0 0x0L

let decode_range x r = r *. (Float.ldexp (2.0 *. Int64.to_float x) (-32) -. 1.0)

let squash x =
  let f s m x' =
    m |> Int64.logand (x' |> Int64.logor (Int64.shift_right x' s))
  in
  x
  |> Int64.logand 0x5555555555555555L
  |> f 1 0x3333333333333333L |> f 2 0x0f0f0f0f0f0f0f0fL
  |> f 4 0x00ff00ff00ff00ffL |> f 8 0x0000ffff0000ffffL
  |> f 16 0x00000000ffffffffL

let deinterleave x = (squash x, squash (Int64.shift_right x 1))

let error_with_precision bits =
  let latBits = bits / 2 in
  let lonBits = bits - latBits in
  let latErr = Float.ldexp 180.0 (-latBits)
  and lonErr = Float.ldexp 360.0 (-lonBits) in
  (latErr, lonErr)

let decode hash =
  match base32_decode hash with
  | Error e -> Error e
  | Ok inthash ->
      let bits = 5 * String.length hash in
      let fullHash = Int64.shift_left inthash (64 - bits) in
      let latI, lonI = deinterleave fullHash in
      let lat = decode_range latI 90.0 and lon = decode_range lonI 180.0 in
      let latE, lonE = error_with_precision bits in
      let latE2, lonE2 = (latE *. 0.5, lonE *. 0.5) in
      Ok ((lat +. latE2, lon +. latE2), (latE2, lonE2))
