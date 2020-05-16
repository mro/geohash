
open Lib

let () = assert (1 + 1 = 2)

let test_decode () =
  (* https://github.com/francoisroyer/ocaml-geohash/blob/master/geohash.ml#L200 *)
  let ((lat,lon),(dlat,dlon)) = Geohash.decode "u4pruydqqvj" in
  Assert2.equals_float "lat" 57.649111 lat 1e-6;
  Assert2.equals_float "lon" 10.407440 lon 1e-6;
  Assert2.equals_float "dlat" 1.34110450745e-06 dlat 1e-17;
  Assert2.equals_float "dlon" 1.34110450745e-06 dlon 1e-17;
  (* https://github.com/mariusae/ocaml-geohash/blob/master/lib_test/test.ml#L7 *)
  let ((lat,lon),(dlat,dlon)) = Geohash.decode "9q8yyk8yuv" in
  Assert2.equals_float "lat"    37.7749295  lat 1e-5;
  Assert2.equals_float "lon" (-122.4194155) lon 1e-6;
  Assert2.equals_float "dlat" 5.36441802979e-06 dlat 1e-17;
  Assert2.equals_float "dlon" 1.07288360596e-05 dlon 1e-16

(* test string to int64 + prec *)

let () =
  test_decode ()

