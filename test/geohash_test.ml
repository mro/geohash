(*
 * geohash_test.ml
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

open Optint.Int63
open Lib.Geohash

let assert_equals_int64 (test_name : string) (expected : t) (result : t) : 'a =
  Assert.assert_equals test_name to_string expected result

let test_len () =
  assert ("zzzzzzzzzzzZ" < "zzzzzzzzzzzz");
  assert ("zzzzzzzzzzzz" < "zzzzzzzzzzzz ");
  assert ("zzzzzzzzzzzz" < "zzzzzzzzzzzz1");
  assert ("zzzzzzzzzzzz" > "u28brs0s00040");
  assert ("z" > "aa");
  assert ("a" < "b");
  assert (12 < ("u28brs0s00040" |> String.length))

(*

let test_spread () =
  (of_int 0x3) |> spread |> to_string
  |> Assert2.equals_string "test_spread #0" "0x5";
  shift_left ((of_int 0x3) |> spread) 1
  |> to_string
  |> Assert2.equals_string "test_spread #1" "0xa";
  shift_left (of_int 0xFFFFFFFF) 1
  |> spread |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_spread #1" "0x5555555555555554";
  0xFFFFL |> spread |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_spread #0" "0x55555555";
  shift_left 0xFFFFL 1 |> spread |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_spread #1" "0x155555554"

let test_interleave () =
  (0x3L, 0x3L) |> interleave |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_interleave #0" "0xf";
  (0x3L, 0x1L) |> interleave |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_interleave #1" "0x7"

let test_deinterleave () =
  let a, b = 0x7L |> deinterleave in
  a |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_deinterleave #0" "0x3";
  b |> Printf.sprintf "%#Lx"
  |> Assert2.equals_string "test_deinterleave #1" "0x1"

let test_quantize () =
  let la, lo = quantize (57.649111, 10.407440) in
  Assert2.equals_float "test_quantize #1" 3523045016. (to_float la) 0.1;
  Assert2.equals_float "test_quantize #2" 2271649243. (to_float lo) 0.1;
  shift_right ((la, lo) |> interleave) 4
  |> base32_encode 12
  |> Assert2.equals_string "test_quantize #3" "u4pruydqqvjw"
*)

let concat hi lo = shift_left (hi |> of_int) 32 |> logor (lo |> of_int)

let test_base32_decode () =
  let t i a b =
    let x = a |> base32_decode |> Result.get_ok in
    (* Printf.eprintf "decode %#x\n" x; *)
    x |> assert_equals_int64 (Printf.sprintf "test_base32_decode #%d" i) b
  in
  t 10 "tuvz4p141zc1" (concat 0xceb7f25 0x4240fd61);
  t 11 "ezs42" (concat 0 0xdfe082);
  (* t 12 "u4pruydqqvj" (concat 0x6895be 0xbccb5b71); *)
  t 13 "zzs000000000" (concat 0xfff0000 0x00000000)

let test_base32_encode () =
  let t i p a b =
    shift_right a (5 * (12 - p))
    |> base32_encode p
    |> Assert2.equals_string (Printf.sprintf "test_base32_encode #%d" i) b
  in
  t 10 12 (concat 0xceb7f25 0x4240fd61) "tuvz4p141zc1";
  t 20 4 (concat 0xceb7f25 0x4240fd61) "tuvz";
  t 30 11 (concat 0xceb7f25 0x4240fd61) "tuvz4p141zc";
  base32_encode 12 (concat 0xff00000 0x00000000)
  |> Assert2.equals_string "test_base32_encode #1" "zw0000000000"

let test_quantize () =
  let t i wgs84 b =
    shift_right (wgs84 |> quantize30 |> interleave) 0
    |> assert_equals_int64 (Printf.sprintf "test_quantize #%d" i) b
  in
  t 10 (27.988056, 86.925278) (concat 0xceb7f25 0x4240fd61)

let test_encode_a () =
  let t i p a b =
    a |> encode p |> Result.get_ok
    |> Assert2.equals_string (Printf.sprintf "test_encode_a #%d" i) b
  in
  t 0 12 (27.988056, 86.925278) "tuvz4p141zc1";
  t 10 12 (-25.382708, -49.265506) "6gkzwgjzn820";
  t 20 12 (57.649111, 10.407440) "u4pruydqqvjw";
  t 30 12 (47.879105, 12.634964) "u28brs0s0004";
  t 40 11 (47.879105, 12.634964) "u28brs0s000";
  t 50 1 (47.879105, 12.634964) "u";
  t 60 0 (47.879105, 12.634964) ""

let test_decode_sunshine () =
  let t i a b =
    let (lat, lon), (dlat, dlon) = a |> decode |> Result.get_ok
    and (lat', lon'), (dlat', dlon') = b in
    Assert2.equals_float (Printf.sprintf "test_decode lat #%d" i) lat' lat 1e-6;
    Assert2.equals_float (Printf.sprintf "test_decode lon #%d" i) lon' lon 1e-6;
    Assert2.equals_float
      (Printf.sprintf "test_decode dlat #%d" i)
      dlat' dlat 1e-17;
    Assert2.equals_float
      (Printf.sprintf "test_decode dlon #%d" i)
      dlon' dlon 1e-17
  in
  (* https://github.com/francoisroyer/ocaml-geohash/blob/master/geohash.ml#L200 *)
  t 0 "u4pruydqqvj"
    ((57.649111, 10.407440), (6.70552253723e-07, 6.70552253723e-07));
  (* https://github.com/mariusae/ocaml-geohash/blob/master/lib_test/test.ml#L7 *)
  t 10 "9q8yyk8yuv"
    ((37.7749308944, -122.419415116), (2.68220901489e-06, 5.36441802979e-06));
  t 20 "u28brs0s0004"
    ((47.879105, 12.634964), (8.38190317154e-08, 1.67638063431e-07))

let test_decode_fail () =
  assert ("u28brs0s00040" |> decode = Error '_');
  assert ("u28brs0s00041" |> decode = Error '_');
  assert ("_" |> decode = Error '_')

let () =
  test_len ();
  (* test_spread ();
              test_interleave ();
           test_deinterleave ();
        test_quantize ();
     test_base32_decode ();
     test_base32_encode ();
  *)
  test_quantize ();
  test_encode_a ();
  test_decode_sunshine ();
  test_decode_fail ()
