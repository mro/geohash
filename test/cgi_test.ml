(*
 * cgi_test.ml
 *
 * Created by Marcus Rohrmoser on 27.05.20.
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

open Lib.Cgi

let ra =
  {
    host = "example.com";
    http_cookie = "";
    path_info = "";
    query_string = "badly";
    request_method = "GET";
    request_uri = "/sub/wrong.cgi?badly";
    scheme = "http";
    script_name = "/sub/wrong.cgi";
    server_port = "80";
  }

(* https://tools.ietf.org/html/rfc3875#section-4.1.5 *)
let test_consolidate_path_info_workaround () =
  let re =
    Ok { ra with path_info = "/sub/wrong.cgi" } |> consolidate |> Result.get_ok
  in
  Assert2.equals_string "test_consolidate_path_info_workaround" "" re.path_info

(* https://tools.ietf.org/html/rfc3875#section-4.1.5 *)
let test_consolidate_path_info_buggy_workaround () =
  let re =
    Ok
      {
        ra with
        path_info = "/sub/wrong.cgi";
        request_uri = "/sub/wrong.cgi/sub/wrong.cgi";
      }
    |> consolidate |> Result.get_ok
  in
  Assert2.equals_string
    "wrong but accepted until 1and1 fixes their shit (prbly never)." ""
    re.path_info

let () =
  test_consolidate_path_info_workaround ();
  test_consolidate_path_info_buggy_workaround ()
