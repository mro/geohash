(*
 * Parse path and Query string 
 *
 * We have either a 
 *
 * path: /<geohash>/<format>
 * or
 * query_string: ?q=<lat><sep><lon>
 *)

module P = struct
  open Tyre

  let lat_lon_pair = float <&> pcre "([,; +]|%2C|%3B|%20)+" *> float

  let geo_uri =
    opt (str "geo:" <|> str "geo%3A") *> lat_lon_pair
    <* opt (pcre "[?]z=[0-9]+" <|> pcre "%3Fz%3D[0-9]+")

  let lat_lon = compile (geo_uri <* stop)

  let qs_lat_lon = compile (str "q=" *> geo_uri <* stop)
end

let coord_from_qs qs = qs |> Tyre.exec P.qs_lat_lon

let coord_from_s s = s |> Tyre.exec P.lat_lon
