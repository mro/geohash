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

let redirect url =
  Printf.printf "HTTP/1.1 %d %s\n" 302 "Found";
  Printf.printf "Location: %s\n" url;
  Printf.printf "\n";
  0

let error status reason =
  Printf.printf "HTTP/1.1 %d %s\n" status reason;
  Printf.printf "Content-type: text/plain; charset=utf-8\n";
  Printf.printf "\n";
  Printf.printf "%s %s.\n" camel reason;
  0

let dump_clob mime clob =
  Printf.printf "Content-type: %s\n" mime;
  Printf.printf "\n";
  Printf.printf "%s" clob;
  0

type req_raw = {
  scheme : string;
  http_cookie : string;
  host : string;
  path_info : string;
  request_method : string;
  request_uri : string;
  query_string : string;
  server_port : string;
}

(* https://tools.ietf.org/html/rfc7231#section-6 *)

(* https://github.com/rixed/ocaml-cgi/blob/master/cgi.ml#L169 *)
let getenv_safe ?default s =
  try Sys.getenv s
  with Not_found -> (
    match default with
    | Some d -> d
    | None -> failwith ("Cgi: the environment variable " ^ s ^ " is not set") )

(* very basic, minimal parsing only *)
let request_from_env () =
  try
    let name = Sys.getenv "SERVER_NAME" in
    let ret =
      {
        http_cookie = getenv_safe ~default:"" "HTTP_COOKIE";
        host = getenv_safe ~default:name "HTTP_HOST";
        path_info = getenv_safe ~default:"" "PATH_INFO";
        query_string = getenv_safe ~default:"" "QUERY_STRING";
        request_method = Sys.getenv "REQUEST_METHOD";
        request_uri = Sys.getenv "REQUEST_URI";
        scheme = (match Sys.getenv "HTTPS" with "on" -> "https" | _ -> "http");
        server_port = Sys.getenv "SERVER_PORT";
      }
    in
    Ok ret
  with Not_found -> Error "Not Found."
