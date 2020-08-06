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

let globe = "🌐"

open Lib
open Lib.Cgi

let handle_query_string qs =
  match Route.coord_from_qs qs with
  | Error _ -> error 406 "Cannot parse query string."
  | Ok coord -> (
      let prec =
        (* rough estimate: digits ~ length - q= and  3 separators
         * bits = digits * ln(10)/ln(2)
         * geohash has 5 bit per char, 
         * but no less than 2 and no more than 12 *)
        float ((qs |> String.length) - 5) *. 3.3219 /. 5.
        |> ceil |> truncate |> max 2 |> min 12
      in
      match Lib.Geohash.encode prec coord with
      | Ok hash -> hash |> redirect
      | _ -> error 406 "Cannot encode coords." )

let handle_hash req =
  match req.path_info |> String.split_on_char '/' with
  | [ ""; hash ] -> (
      match Lib.Geohash.decode hash with
      | Error _ -> error 406 "Cannot decode hash."
      | Ok ((lat, lon), (dlat, dlon)) ->
          let mime = "text/xml"
          and xslt = "gpx2html.xslt"
          and base = "http://purl.mro.name/geohash" in
          Printf.printf "%s: %s\n" "Content-Type" mime;
          Printf.printf "\n";
          Printf.printf
            "<?xml version='1.0'?><!-- \
             https://www.topografix.com/GPX/1/1/gpx.xsd -->\n\
             <?xml-stylesheet type='text/xsl' href='%s'?>\n\
             <gpx xmlns='http://www.topografix.com/GPX/1/1' version='1.1' \
             creator='%s'>\n\
            \  <metadata>\n\
            \    <link href='%s://%s:%s%s'/>\n\
            \    <bounds minlat='%f' minlon='%f' maxlat='%f' maxlon='%f'/>\n\
            \  </metadata>\n\
            \  <wpt lat='%f' lon='%f'>\n\
            \    <name>#%s</name>\n\
            \    <link href='%s://%s:%s%s'/>\n\
            \  </wpt>\n\
             </gpx>"
            xslt base req.scheme req.host req.server_port req.request_uri
            (lat -. dlat) (lon -. dlon) (lat +. dlat) (lon +. dlon) lat lon hash
            req.scheme req.host req.server_port req.request_uri;
          0 )
  | _ -> error 404 "Not found"

let handle req =
  let mercator_birth = "u154c" in
  match req.request_method with
  | "GET" -> (
      match req.path_info with
      | "/about" -> dump_clob "text/xml" Res.doap_rdf
      | "/LICENSE" -> dump_clob "text/plain" Res._LICENSE
      | "/doap2html.xslt" -> dump_clob "text/xml" Res.doap2html_xslt
      | "/gpx2html.xslt" -> dump_clob "text/xml" Res.gpx2html_xslt
      | "" -> [ req.request_uri; "/" ] |> String.concat "" |> redirect
      | "/" -> (
          match req.query_string with
          | "" ->
              [ req.request_uri; mercator_birth ]
              |> String.concat "" |> redirect
          | s -> s |> handle_query_string )
      | _ -> handle_hash req )
  | _ -> error 405 "Method Not Allowed"
