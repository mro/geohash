
module P = struct
  let world = ((-180.,180.),(-90.,90.))

  let mid = function
    (mi,ma) -> (mi +. ma) /. 2.

  (* may change to halfspan *)
  let span = function
    (mi,ma) -> ma -. mi

  let is_bit_set idx bits =
    0 != bits land (1 lsl idx)

  let b32_int_of_char = function
    | '0' -> Ok 0x00 | '1' -> Ok 0x01 | '2' -> Ok 0x02 | '3' -> Ok 0x03 | '4' -> Ok 0x04
    | '5' -> Ok 0x05 | '6' -> Ok 0x06 | '7' -> Ok 0x07 | '8' -> Ok 0x08 | '9' -> Ok 0x09
    | 'b' -> Ok 0x0a | 'c' -> Ok 0x0b | 'd' -> Ok 0x0c | 'e' -> Ok 0x0d | 'f' -> Ok 0x0e
    | 'g' -> Ok 0x0f | 'h' -> Ok 0x10 | 'j' -> Ok 0x11 | 'k' -> Ok 0x12 | 'm' -> Ok 0x13
    | 'n' -> Ok 0x14 | 'p' -> Ok 0x15 | 'q' -> Ok 0x16 | 'r' -> Ok 0x17 | 's' -> Ok 0x18
    | 't' -> Ok 0x19 | 'u' -> Ok 0x1a | 'v' -> Ok 0x1b | 'w' -> Ok 0x1c | 'x' -> Ok 0x1d
    | 'y' -> Ok 0x1e | 'z' -> Ok 0x1f
    | ch  -> Error ch

  let rec decode_bits bits idx lonoff area =
    if idx < 0
    then area
    else
      let hi = is_bit_set idx bits in
      let choose = fun minmax ->
        let m = mid minmax
        and (a,b) = minmax in
        if hi
        then (m,b)
        else (a,m)
      in
      let (lon,lat) = area in
      begin if lonoff = (idx mod 2)
        then (lon |> choose, lat)
        else (lon          , lat |> choose)
      end |> decode_bits bits (idx - 1) lonoff

  let rec decode_chars hash idx max area =
    if idx >= max
    then area
    else match area with
    | Error e  -> Error e
    | Ok area' -> match idx
        |> String.get hash
        |> b32_int_of_char with
      | Error e -> Error e
      | Ok bits -> (Ok (decode_bits bits 4 (idx mod 2) area'))
        |> decode_chars hash (idx + 1) max
 end

let decode hash =
  match P.decode_chars hash 0 (String.length hash) (Ok P.world) with
  | Ok (lon,lat) -> Ok ((P.mid lat, P.mid lon),(P.span lat, P.span lon))
  | other -> other

