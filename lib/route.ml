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

  let q_lat_lon =
    let to_ (lat, lon) = (lat, lon) and of_ (lat, lon) = (lat, lon) in
    conv to_ of_ (str "q=" *> float <&> pcre "([,; +]|%2C|%3B|%20)+" *> float <* stop)

  let q_lat_lon' = compile q_lat_lon
end

let coord_from_qs qs = Tyre.exec P.q_lat_lon' qs
