
open Lib

let () = assert (1 + 1 = 2)

let test_encode_sunshine () =
  (* https://github.com/francoisroyer/ocaml-geohash/blob/master/geohash.ml#L200 *)
  begin match Geohash.encode 11 (57.649111,10.407440) with
  | Error _ -> assert false
  | Ok hash -> Assert2.equals_string "hash" "u4pruydqqvj" hash
  end

let test_decode_sunshine () =
  (* https://github.com/francoisroyer/ocaml-geohash/blob/master/geohash.ml#L200 *)
  begin match Geohash.decode "u4pruydqqvj" with
  | Error _ -> assert false
  | Ok ((lat,lon),(dlat,dlon)) ->
    Assert2.equals_float "lat" 57.649111 lat 1e-6;
    Assert2.equals_float "lon" 10.407440 lon 1e-6;
    Assert2.equals_float "dlat" 1.34110450745e-06 dlat 1e-17;
    Assert2.equals_float "dlon" 1.34110450745e-06 dlon 1e-17
  end;
  (* https://github.com/mariusae/ocaml-geohash/blob/master/lib_test/test.ml#L7 *)
  begin match Geohash.decode "9q8yyk8yuv" with
  | Error _ -> assert false
  | Ok ((lat,lon),(dlat,dlon)) ->
    Assert2.equals_float "lat"    37.7749295  lat 1e-5;
    Assert2.equals_float "lon" (-122.4194155) lon 1e-6;
    Assert2.equals_float "dlat" 5.36441802979e-06 dlat 1e-17;
    Assert2.equals_float "dlon" 1.07288360596e-05 dlon 1e-16
  end

let test_decode_failure () =
  (* https://github.com/francoisroyer/ocaml-geohash/blob/master/geohash.ml#L200 *)
  begin match Geohash.decode "u4prUydqqvj" with
  | Ok _     -> assert false
  | Error ch -> assert (ch = 'U')
  end

(* test string to int64 + prec *)

let () =
  test_encode_sunshine ();
  test_decode_sunshine ();
  test_decode_failure ()

