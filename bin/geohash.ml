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

let () =
  let status = match Lib.Cgi.request_from_env () with
  | Ok req  -> Cgi.handle req
  | Error _ -> Sys.argv |> Array.to_list |> Shell.exec in
  exit status

