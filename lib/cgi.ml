(*
 * cgi.ml
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

let camel = "🐫"

module Os = struct
  let getenv = Sys.getenv

  (* https://github.com/rixed/ocaml-cgi/blob/master/cgi.ml#L169 *)
  let getenv_safe ?default s =
    try getenv s
    with Not_found -> (
      match default with
      | Some d -> d
      | None -> failwith ("Cgi: the environment variable " ^ s ^ " is not set") )
end

let redirect url =
  let status = 302
  and reason = "Found"
  and mime = "text/plain; charset=utf-8" in
  Printf.printf "%s: %d %s\n" "Status" status reason;
  Printf.printf "%s: %s\n" "Content-Type" mime;
  Printf.printf "%s: %s\n" "Location" url;
  Printf.printf "\n";
  Printf.printf "%s %s.\n" camel reason;
  0

let error status reason =
  let mime = "text/plain; charset=utf-8" in
  Printf.printf "%s: %d %s\n" "Status" status reason;
  Printf.printf "%s: %s\n" "Content-Type" mime;
  Printf.printf "\n";
  Printf.printf "%s %s.\n" camel reason;
  0

let dump_clob mime clob =
  Printf.printf "%s: %s\n" "Content-Type" mime;
  Printf.printf "\n";
  Printf.printf "%s" clob;
  0

type req_raw = {
  host : string;
  http_cookie : string;
  path_info : string;
  query_string : string;
  request_method : string;
  scheme : string;
  script_name : string;
  server_port : string;
}

let consolidate req' =
  match req' with
  | Error _ -> req'
  | Ok req -> (
      (* despite https://tools.ietf.org/html/rfc3875#section-4.1.13 1und1.de
       * webhosting returns the script_name instead an empty or nonex path_info in
       * case *)
      match req.path_info = req.script_name with
      | true -> Ok { req with path_info = "" }
      | false -> req' )

let request_uri req =
  match req.query_string with
  | "" -> req.script_name ^ req.path_info
  | qs -> req.script_name ^ req.path_info ^ "?" ^ qs

(* Almost trivial. https://tools.ietf.org/html/rfc3875 *)
let request_from_env () =
  try
    let name = Os.getenv "SERVER_NAME" in
    Ok
      {
        host = Os.getenv_safe ~default:name "HTTP_HOST";
        http_cookie = Os.getenv_safe ~default:"" "HTTP_COOKIE";
        path_info = Os.getenv_safe ~default:"" "PATH_INFO";
        query_string = Os.getenv_safe ~default:"" "QUERY_STRING";
        request_method = Os.getenv "REQUEST_METHOD";
        (* request_uri = Os.getenv "REQUEST_URI"; *)
        scheme =
          ( match Os.getenv_safe ~default:"" "HTTPS" with
          | "on" -> "https"
          | _ -> "http" );
        script_name = Os.getenv "SCRIPT_NAME";
        server_port = Os.getenv "SERVER_PORT";
      }
  with Not_found -> Error "Not Found."
