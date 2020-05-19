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
