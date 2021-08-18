(*
 * route_test.ml
 *
 * Created by Marcus Rohrmoser on 16.05.20.
 * Copyright © 2020-2021 Marcus Rohrmoser mobile Software http://mro.name/~me. All rights reserved.
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

open Lib.Route

let test_qs () =
  assert (
    match coord_from_qs "q=1.2,3.4" with Ok (1.2, 3.4) -> true | _ -> false);
  assert (
    match coord_from_qs "q=geo%3A47.5440%2C15.4396%3Fz%3D12" with
    | Ok (47.5440, 15.4396) -> true
    | _ -> false);
  match coord_from_qs "q=1.u2 , ; 3.4" with
  | Error (`NoMatch (_, original)) -> assert (original != "")
  | _ -> assert false

let () = test_qs ()
