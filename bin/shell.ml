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

let print_version () =
  let exe = Filename.basename Sys.executable_name in
  Printf.printf "%s: https://mro.name/%s/v%s, built: %s\n" exe "geohash" Version.git_sha Version.date;
  0

let print_help () =
  let exe = Filename.basename Sys.executable_name in
  Printf.printf "
Convert geo coordinates to geohash and vice versa.

If run from commandline:

SYNOPSIS

  $ %s -v

  $ %s -h

  $ %s --doap

  $ %s 'geo:47.67726,12.47077?z=19'

" exe exe exe exe;
  0

let err i msgs =
  let exe = Filename.basename Sys.executable_name in
  msgs
    |> List.cons exe
    |> String.concat ": "
    |> prerr_endline;
  i

let convert () =
  err 3 ["Not implemented yet"]

let exec args =
  match args |> List.tl with
  | []  -> convert ()
  | arg -> match List.hd arg with
    | "-v"
    | "--version" -> print_version ()
    | "--doap"    -> Printf.printf "%s" Lib.Res.doap_rdf; 0
    | "-h"
    | "--help"
    | _           -> print_help ()
