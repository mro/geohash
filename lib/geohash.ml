(*
 * geohash.ml
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

open Optint.Int63

(*
 * 60 bits are fine, because
 * - nobody uses 13 chars = 65 bit
 * - 12 geohash characters equal 60 bit
 * - ocaml has efficient int63 but not int64
 *)

(* wgs84 -> 30 bit geohash *)
let quantize30 (lat, lng) =
  let f r x = Float.ldexp ((x /. r) +. 0.5) 30 |> of_float in
  (f 180. lat, f 360. lng)

(* 30 bit geohash -> wgs84 *)
let dequantize30 (lat, lon) =
  let f r x = r *. (Float.ldexp (x |> to_float) (-30) -. 0.5) in
  (f 180. lat, f 360. lon)

let x00000000ffffffff = of_int64 0x00000000ffffffffL

let x0000ffff0000ffff = of_int64 0x0000ffff0000ffffL

let x00ff00ff00ff00ff = of_int64 0x00ff00ff00ff00ffL

let x0f0f0f0f0f0f0f0f = of_int64 0x0f0f0f0f0f0f0f0fL

let x3333333333333333 = of_int64 0x3333333333333333L

let x5555555555555555 = of_int64 0x5555555555555555L

let spread x =
  let f s m x' = m |> logand (x' |> logor (shift_left x' s)) in
  x |> f 16 x0000ffff0000ffff |> f 8 x00ff00ff00ff00ff |> f 4 x0f0f0f0f0f0f0f0f
  |> f 2 x3333333333333333 |> f 1 x5555555555555555

let squash x =
  let f s m x' = m |> logand (x' |> logor (shift_right x' s)) in
  x |> logand x5555555555555555 |> f 1 x3333333333333333
  |> f 2 x0f0f0f0f0f0f0f0f |> f 4 x00ff00ff00ff00ff |> f 8 x0000ffff0000ffff
  |> f 16 x00000000ffffffff

let interleave (x, y) = spread x |> logor (shift_left (spread y) 1)

let deinterleave x = (squash x, squash (shift_right x 1))

let alphabet = Bytes.of_string "0123456789bcdefghjkmnpqrstuvwxyz"

let b32_int_to_char i = Bytes.get alphabet i

let b32_int_of_char c =
  (* if we want it fast, either do binary search or construct a sparse LUT from chars 0-z -> int *)
  match c |> Bytes.index_opt alphabet with None -> Error c | Some i -> Ok i

let x1f = of_int 0x1f

(* encode the chars * 5 low bits of x *)
let base32_encode chars x =
  let rec f i x' b =
    match i with
    | -1 -> b
    | _ ->
        x' |> logand x1f |> to_int |> b32_int_to_char |> Bytes.set b i;
        f (i - 1) (shift_right x' 5) b
  in
  chars |> Bytes.create |> f (chars - 1) x |> Bytes.to_string

let base32_decode hash =
  let len = hash |> String.length in
  match len <= 12 with
  | false -> Error '_'
  | true ->
      let rec f idx x =
        match len - idx with
        | 0 -> Ok x
        | _ ->
            Result.bind
              (hash.[idx] |> b32_int_of_char)
              (fun v -> v |> of_int |> logor (shift_left x 5) |> f (idx + 1))
      in
      f 0 zero

let encode chars wgs84 =
  match 0 <= chars && chars <= 12 with
  | false -> Error chars
  | true ->
      let h60 = wgs84 |> quantize30 |> interleave in
      Ok (shift_right h60 (60 - (5 * chars)) |> base32_encode chars)

let error_with_precision bits =
  let latBits = bits / 2 in
  let lonBits = bits - latBits in
  let latErr = Float.ldexp 180. (-latBits)
  and lonErr = Float.ldexp 360. (-lonBits) in
  (latErr, lonErr)

let decode hash =
  Result.bind (base32_decode hash) (fun h60 ->
      let bits = 5 * String.length hash in
      let lat, lon = shift_left h60 (60 - bits) |> deinterleave |> dequantize30
      and latE, lonE = error_with_precision bits in
      let latE2, lonE2 = (latE *. 0.5, lonE *. 0.5) in
      Ok ((lat +. latE2, lon +. lonE2), (latE2, lonE2)))
