(*
 * shell.ml
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

(* https://caml.inria.fr/pub/docs/manual-ocaml/libref/Sys.html *)

let err i msgs =
  let exe = Filename.basename Sys.executable_name in
  msgs |> List.cons exe |> String.concat ": " |> prerr_endline;
  i

let to_hash h = Ok [ h; "not implemented yet." ]

let print_version () =
  let exe = Filename.basename Sys.executable_name in
  Printf.printf "%s: https://mro.name/%s/v%s, built: %s\n" exe "geohash"
    Version.git_sha Version.date;
  0

let print_help () =
  let exe = Filename.basename Sys.executable_name in
  Printf.printf
    "\n\
     Convert one lat,lon pair or geohash to gpx with bbox and geohash comment.\n\n\
     Works as a webserver CGI or commandline converter.\n\n\
     If run from commandline:\n\n\
     SYNOPSIS\n\n\
    \  $ %s -v\n\n\
    \  $ %s -h\n\n\
    \  $ %s --doap\n\n\
    \  $ %s 'geo:47.67726,12.47077?z=19'\n\n"
    exe exe exe exe;
  0

let exec args =
  match args |> List.tl with
  | [ "-h" ] | [ "--help" ] -> print_help ()
  | [ "-v" ] | [ "--version" ] -> print_version ()
  | [ "--doap" ] ->
      Printf.printf "%s" Lib.Res.doap_rdf;
      0
  | [ i ] ->
      (i |> to_hash |> function
       | Ok h -> h |> String.concat " -> " |> Printf.printf "%s"
       | Error _ -> "ouch" |> Printf.printf "%s");
      0
  | _ -> err 2 [ "get help with -h" ]
