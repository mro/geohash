(*
 * cgi.ml
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

let globe = "🌐"

open Lib
open Lib.Cgi

let handle_hash oc req =
  match req.path_info |> String.split_on_char '/' with
  | [ ""; hash ] -> (
      match Lib.Geohash.decode hash with
      | Error _ -> error oc 406 "Cannot decode hash."
      | Ok ((lat, lon), (dlat, dlon)) ->
          let mime = "text/xml"
          and xslt = "gpx2html.xslt"
          and uri = req |> request_uri
          and base = "http://purl.mro.name/geohash" in
          Printf.fprintf oc "%s: %s\n" "Content-Type" mime;
          Printf.fprintf oc "\n";
          Printf.fprintf oc
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
            xslt base req.scheme req.host req.server_port uri (lat -. dlat)
            (lon -. dlon) (lat +. dlat) (lon +. dlon) lat lon hash req.scheme
            req.host req.server_port uri;
          0)
  | _ -> error oc 404 "Not found"

let handle oc req =
  let mercator_birth = "u154c" and uri = req |> request_uri in
  match req.request_method with
  | "GET" -> (
      match req.path_info with
      | "/about" -> dump_clob oc "text/xml" Res.doap_rdf
      | "/LICENSE" -> dump_clob oc "text/plain" Res._LICENSE
      | "/doap2html.xslt" -> dump_clob oc "text/xml" Res.doap2html_xslt
      | "/gpx2html.xslt" -> dump_clob oc "text/xml" Res.gpx2html_xslt
      | "" -> uri ^ "/" |> redirect oc
      | "/" -> (
          match req.query_string with
          | "" -> uri ^ mercator_birth |> redirect oc
          | qs -> (
              match qs |> Route.coord_from_qs with
              | Error (`NoMatch (_, s')) ->
                  error oc 406 ("Cannot encode coords: '" ^ s' ^ "'")
              | Error (`ConverterFailure _) ->
                  error oc 406 "Cannot encode coords."
              | Ok co -> (
                  (* actually logic :-( *)
                  let prec =
                    (* rough estimate: digits ~ length - q= and  3 separators
                     * bits = digits * ln(10)/ln(2)
                     * geohash has 5 bit per char, *)
                    float ((qs |> String.length) - 5) *. 3.3219 /. 5.
                    |> ceil |> truncate
                    (* but no less than 2 and no more than 12 *)
                    |> max 2
                    |> min 12
                  in
                  match co |> Lib.Geohash.encode prec with
                  | Error _ -> error oc 406 "Cannot encode coords."
                  | Ok hash -> hash |> redirect oc)))
      | _ -> handle_hash oc req)
  | _ -> error oc 405 "Method Not Allowed"
