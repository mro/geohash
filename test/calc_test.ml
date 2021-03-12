(*
 * math_test.ml
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

open Lib

let test_spread () =
  0x3L |> Calc.spread |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_spread #0" "0x5";
  Int64.shift_left (0x3L |> Calc.spread) 1
  |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_spread #1" "0xa";
  Int64.shift_left 0xFFFFFFFFL 1
  |> Calc.spread |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_spread #1" "0x5555555555555554";
  0xFFFFL |> Calc.spread |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_spread #0" "0x55555555";
  Int64.shift_left 0xFFFFL 1 |> Calc.spread |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_spread #1" "0x155555554"

let test_interleave () =
  (0x3L, 0x3L) |> Calc.interleave |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_interleave #0" "0xf";
  (0x3L, 0x1L) |> Calc.interleave |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_interleave #1" "0x7"

let test_deinterleave () =
  let a, b = 0x7L |> Calc.deinterleave in
  a |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_deinterleave #0" "0x3";
  b |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_deinterleave #1" "0x1"

let test_quantize () =
  let la, lo = Calc.quantize (57.649111, 10.407440) in
  Assert2.equals_float "test_quantize #1" 3523045016. (Int64.to_float la) 0.1;
  Assert2.equals_float "test_quantize #2" 2271649243. (Int64.to_float lo) 0.1;
  Int64.shift_right ((la, lo) |> Calc.interleave) 4
  |> Calc.base32_encode 12
  |> Assert2.equals_string "test_quantize #3" "u4pruydqqvjw"

let test_base32_encode_a () =
  Calc.base32_encode 12 0xfff000000000000L
  |> Assert2.equals_string "test_base32_encode_a #1" "zzs000000000"

let test_encode_a () =
  (-25.382708, -49.265506) |> Calc.encode 12 |> Result.get_ok
  |> Assert2.equals_string "test_base32_encode_a #0" "6gkzwgjzn820";
  (57.649111, 10.407440) |> Calc.encode 12 |> Result.get_ok
  |> Assert2.equals_string "test_base32_encode_a #1" "u4pruydqqvjw"

let test_base32_decode () =
  "ezs42" |> Calc.base32_decode |> Result.get_ok |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_base32_decode #1" "0xdfe082";
  "u4pruydqqvj" |> Calc.base32_decode |> Result.get_ok |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_base32_decode #1" "0x6895bebccb5b71"

let test_decode_sunshine () =
  (* https://github.com/francoisroyer/ocaml-geohash/blob/master/geohash.ml#L200 *)
  (let (lat, lon), (dlat, dlon) =
     "u4pruydqqvj" |> Calc.decode |> Result.get_ok
   in
   Assert2.equals_float "lat 0" 57.649111 lat 1e-6;
   Assert2.equals_float "lon 0" 10.407440 lon 1e-6;
   Assert2.equals_float "dlat 0" 6.70552253723e-07 dlat 1e-17;
   Assert2.equals_float "dlon 0" 6.70552253723e-07 dlon 1e-17);
  (* https://github.com/mariusae/ocaml-geohash/blob/master/lib_test/test.ml#L7 *)
  let (lat, lon), (dlat, dlon) = "9q8yyk8yuv" |> Calc.decode |> Result.get_ok in
  Assert2.equals_float "lat 1" 37.7749308944 lat 1e-6;
  Assert2.equals_float "lon 1" (-122.419415116) lon 1e-6;
  Assert2.equals_float "dlat 1" 2.68220901489e-06 dlat 1e-17;
  Assert2.equals_float "dlon 1" 5.36441802979e-06 dlon 1e-17

let () =
  test_spread ();
  test_interleave ();
  test_deinterleave ();
  test_quantize ();
  test_base32_encode_a ();
  test_encode_a ();
  test_base32_decode ();
  test_decode_sunshine ()
