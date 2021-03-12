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

(* Inspired by https://mmcloughlin.com/posts/geohash-assembly
 * and https://github.com/mmcloughlin/geohash/blob/master/geohash.go 
 * and https://github.com/mmcloughlin/deconstructedgeohash/blob/master/geohash.go *)

open Int64

(* wgs84 -> geohash *)
let quantize (lat, lng) =
  let f r x = Float.ldexp ((x /. r) +. 1.) (32 - 1) |> of_float in
  (f 90. lat, f 180. lng)

(* geohash -> wgs84 *)
let dequantize (lat, lon) =
  let f r x = r *. (Float.ldexp (x |> to_float) (1 - 32) -. 1.) in
  (f 90. lat, f 180. lon)

let spread x =
  let f s m x' = m |> logand (x' |> logor (shift_left x' s)) in
  x |> f 16 0x0000ffff0000ffffL |> f 8 0x00ff00ff00ff00ffL
  |> f 4 0x0f0f0f0f0f0f0f0fL |> f 2 0x3333333333333333L
  |> f 1 0x5555555555555555L

let squash x =
  let f s m x' = m |> logand (x' |> logor (shift_right x' s)) in
  x |> logand 0x5555555555555555L |> f 1 0x3333333333333333L
  |> f 2 0x0f0f0f0f0f0f0f0fL |> f 4 0x00ff00ff00ff00ffL
  |> f 8 0x0000ffff0000ffffL |> f 16 0x00000000ffffffffL

let interleave (x, y) = spread x |> logor (shift_left (spread y) 1)

let deinterleave x = (squash x, squash (shift_right x 1))

let base32_encode chars x =
  let alpha = "0123456789bcdefghjkmnpqrstuvwxyz" in
  let rec f i x' b =
    match i with
    | -1 -> b
    | _ ->
        Bytes.set b i alpha.[x' |> logand 0x1fL |> to_int];
        f (i - 1) (shift_right x' 5) b
  in
  Bytes.create chars |> f (chars - 1) x |> Bytes.to_string

let base32_decode hash =
  let len = String.length hash in
  let rec f idx x =
    match len - idx with
    | 0 -> Ok x
    | _ -> (
        match hash.[idx] |> Iter.P.b32_int_of_char with
        | Error e -> Error e
        | Ok v -> f (idx + 1) (v |> of_int |> logor (shift_left x 5)))
  in
  f 0 0x0L

let encode chars wgs84 =
  let h64 = wgs84 |> quantize |> interleave in
  Ok (shift_right h64 4 |> base32_encode chars)

let error_with_precision bits =
  let latBits = bits / 2 in
  let lonBits = bits - latBits in
  let latErr = Float.ldexp 180. (-latBits)
  and lonErr = Float.ldexp 360. (-lonBits) in
  (latErr, lonErr)

let decode hash =
  match base32_decode hash with
  | Error e -> Error e
  | Ok inthash ->
      let bits = 5 * String.length hash in
      let lat, lon =
        shift_left inthash (64 - bits) |> deinterleave |> dequantize
      and latE, lonE = error_with_precision bits in
      let latE2, lonE2 = (latE *. 0.5, lonE *. 0.5) in
      Ok ((lat +. latE2, lon +. lonE2), (latE2, lonE2))
