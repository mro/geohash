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
open Lib
open Lib.Cgi


let w s =
  print_string s;
  print_string "\n"

let va n =
  print_string "<li>";
  print_string n;
  print_string ": ";
  let v = Cgi.getenv_safe ~default:"-" n in
    (* TODO: escape *)
    print_string v;
  print_string "</li>";
  print_string "\n"

let dump_headers_all () =
  w "HTTP/1.1 200 Ok";
  w "Content-type: text/html; charset=utf-8";
  w "";
  w "<html>
<head><title>Hello, Worλd</title></head>
<body>
<h1>OCaml, where art thou 🐫!</h1>
<p>";
  let cwd = Sys.getcwd () in
    w cwd;
  w "</p>
<ul>";
  va "HOME";
  va "HTTPS";
  va "HTTP_HOST";
  va "HTTP_COOKIE";
  va "HTTP_ACCEPT";
  va "REMOTE_ADDR";
  va "REMOTE_USER";
  va "REQUEST_METHOD" ;
  va "REQUEST_URI";
  va "PATH_INFO";
  va "QUERY_STRING";
  va "SERVER_NAME";
  va "SERVER_PORT";
  va "SERVER_SOFTWARE";
  w "</ul>
</body>
</html>";
  0
let print_request req' =
  let req : Cgi.req_raw = req' in
  let cwd = Sys.getcwd () in
  Printf.printf "HTTP/1.1 %d %s\n" 202 "Accepted";
  w "Content-type: text/html; charset=utf-8" ;
  w "" ;
  w "<html>
<head><title>Hello, Worλd</title></head>
<body>
<h1>OCaml, where art thou 🐫!</h1>
<p>" ;
  w cwd ;
  w "</p>
<ul>";
  Printf.printf "<li>%s: %s</li>\n" "HTTPS"           req.scheme ;
  Printf.printf "<li>%s: %s</li>\n" "HTTP_COOKIE"     req.http_cookie ;
  Printf.printf "<li>%s: %s</li>\n" "HTTP_HOST"       req.host ;
  Printf.printf "<li>%s: %s</li>\n" "PATH_INFO"       req.path_info ;
  Printf.printf "<li>%s: %s</li>\n" "QUERY_STRING"    req.query_string ;
  Printf.printf "<li>%s: %s</li>\n" "REQUEST_METHOD"  req.request_method ;
  Printf.printf "<li>%s: %s</li>\n" "REQUEST_URI"     req.request_uri ;
  Printf.printf "<li>%s: %s</li>\n" "SERVER_PORT"     req.server_port ;
  let parts = String.split_on_char '?' req.request_uri in
  let endp = [ req.scheme; "://"; req.host; ":"; req.server_port; List.hd parts; "/../../../../"; "index.php" ] |> String.concat "" in
  (* we need the authentication info either from the query string (auth_token) or preauthenticated basic auth. *)
  Printf.printf "<li>shaarli: %s</li>\n" endp ;
  w "</ul>
</body>
</html>";
  0



(* put into Lib.Cgi module? *)
let redirect url =
  Printf.printf "HTTP/1.1 %d %s\n" 302 "Found";
  Printf.printf "Location: %s\n" url ;
  Printf.printf "\n" ;
  0

(* put into Lib.Cgi module? *)
let error status reason =
  Printf.printf "HTTP/1.1 %d %s\n" status reason;
  Printf.printf "Content-type: text/plain; charset=utf-8\n" ;
  Printf.printf "\n" ;
  Printf.printf "%s %s.\n" camel reason ;
  0

let dump_clob mime clob =
  Printf.printf "Content-type: %s\n" mime ;
  Printf.printf "\n" ;
  Printf.printf "%s" clob ;
  0

let handle req =
  if "GET" <> req.request_method
  then error 405 "Method Not Allowed"
  else match req.path_info with
    | "/dump"               -> dump_headers_all ()
    | ""                    -> [req.request_uri; "/"; "about"] |> String.concat "" |> redirect
    | "/"                   -> [req.request_uri; "about"] |> String.concat "" |> redirect
    | "/about"              -> dump_clob "text/xml" Lib.Res.doap_rdf
    | "/doap2html.xslt"     -> dump_clob "text/xml" Lib.Res.doap2html_xslt
    | "/LICENSE"            -> dump_clob "text/plain; charset=utf-8" Lib.Res._LICENSE
    | "/README.md"          -> dump_clob "text/plain; charset=utf-8" Lib.Res._README_md
    | "/v1"                 -> "about" |> redirect
    | "/v1/openapi.yaml"    -> dump_clob "application/vnd.oai.openapi;version=3.0.1" Lib.Res.V1.openapi_yaml
    | "/v1/user/api_token"  -> error 501 "Not Implemented"
    | "/v1/posts/add"       -> error 501 "Not Implemented"
    | "/v1/posts/get"       -> print_request req
    | _                     -> error 404 "Not Found"

