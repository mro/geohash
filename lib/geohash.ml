(*
 * geohash.ml
 *
 * Created by Marcus Rohrmoser on 16.05.20.
 * Copyright © 2020-2020 Marcus Rohrmoser mobile Software http://mro.name/me. All rights reserved.
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

module P = struct
  let b32_int_of_char = function
    | '0' -> Ok 0x00 | '1' -> Ok 0x01 | '2' -> Ok 0x02 | '3' -> Ok 0x03 | '4' -> Ok 0x04
    | '5' -> Ok 0x05 | '6' -> Ok 0x06 | '7' -> Ok 0x07 | '8' -> Ok 0x08 | '9' -> Ok 0x09
    | 'b' -> Ok 0x0a | 'c' -> Ok 0x0b | 'd' -> Ok 0x0c | 'e' -> Ok 0x0d | 'f' -> Ok 0x0e
    | 'g' -> Ok 0x0f | 'h' -> Ok 0x10 | 'j' -> Ok 0x11 | 'k' -> Ok 0x12 | 'm' -> Ok 0x13
    | 'n' -> Ok 0x14 | 'p' -> Ok 0x15 | 'q' -> Ok 0x16 | 'r' -> Ok 0x17 | 's' -> Ok 0x18
    | 't' -> Ok 0x19 | 'u' -> Ok 0x1a | 'v' -> Ok 0x1b | 'w' -> Ok 0x1c | 'x' -> Ok 0x1d
    | 'y' -> Ok 0x1e | 'z' -> Ok 0x1f
    | ch  -> Error ch

  let b32_int_to_char = function
    | 0x00 -> "0" | 0x01 -> "1" | 0x02 -> "2" | 0x03 -> "3" | 0x04 -> "4"
    | 0x05 -> "5" | 0x06 -> "6" | 0x07 -> "7" | 0x08 -> "8" | 0x09 -> "9"
    | 0x0a -> "b" | 0x0b -> "c" | 0x0c -> "d" | 0x0d -> "e" | 0x0e -> "f"
    | 0x0f -> "g" | 0x10 -> "h" | 0x11 -> "j" | 0x12 -> "k" | 0x13 -> "m"
    | 0x14 -> "n" | 0x15 -> "p" | 0x16 -> "q" | 0x17 -> "r" | 0x18 -> "s"
    | 0x19 -> "t" | 0x1a -> "u" | 0x1b -> "v" | 0x1c -> "w" | 0x1d -> "x"
    | 0x1e -> "y" | 0x1f -> "z"
    | _    -> "-"

  let world = ((-180., 180.), (-90., 90.))

  let mid = function mi, ma -> (mi +. ma) /. 2.

  (* which bucket/quadrant to go on with *)
  let middle_earth do_lon area hi =
    let lon, lat = area and (lo0, lo1), (la0, la1) = area in
    match (do_lon, hi) with
    | true, true -> ((mid lon, lo1), lat)
    | true, false -> ((lo0, mid lon), lat)
    | false, true -> (lon, (mid lat, la1))
    | false, false -> (lon, (la0, mid lat))

  (* Recurse per bit, encode either lon (even) or lat (odd)
   * and add chunks of 5 bits to a list to be returned finally. *)
  let rec encode_wrk pt charsleft step bits ret area =
    match charsleft with
    | 0 -> ret
    | _ -> (
        let do_lon = 0 = step mod 2 in
        let hi =
          match (do_lon, pt, area) with
          | true, (lo, _), (lon, _) -> lo >= mid lon
          | false, (_, la), (_, lat) -> la >= mid lat
        in
        let area' = middle_earth do_lon area hi and sm5 = step mod 5 in
        let bits' =
          bits lor match hi with true -> 1 lsl (4 - sm5) | false -> 0
        in
        match sm5 with
        | 4 ->
            encode_wrk pt (charsleft - 1) (step + 1) 0
              (ret |> List.cons bits')
              area'
        | _ -> encode_wrk pt charsleft (step + 1) bits' ret area' )

  (* Decode a chunk of 5 bits and refine the area. *)
  let rec decode_bits bits idx lon_off area =
    match idx with
    | -1 -> area
    | _ ->
        0
        != bits land (1 lsl idx)
        |> middle_earth (lon_off = idx mod 2) area
        |> decode_bits bits (idx - 1) lon_off

  (* Decode one character of a geohash and refine the area. *)
  let rec decode_chars hash idx max area =
    match area with
    | Error e -> Error e
    | Ok area' -> (
        match idx - max with
        | 0 -> area
        | _ -> (
            match idx |> String.get hash |> b32_int_of_char with
            | Error e -> Error e
            | Ok bits ->
                Ok (decode_bits bits 4 (idx mod 2) area')
                |> decode_chars hash (idx + 1) max ) )
end

let encode chars coord =
  let lat, lon = coord and area = P.world in
  (* check coord inclusion? *)
  Ok
    ( P.encode_wrk (lon, lat) chars 0 0 [] area
    |> List.rev |> List.map P.b32_int_to_char |> String.concat "" )

let decode hash =
  (* may change to halfspan *)
  let span = function mi, ma -> ma -. mi in
  match P.decode_chars hash 0 (String.length hash) (Ok P.world) with
  | Ok (lon, lat) -> Ok ((P.mid lat, P.mid lon), (span lat, span lon))
  | other -> other
