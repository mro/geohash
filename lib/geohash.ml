
module P = struct
  let b32_int_of_char = function
    | '0' -> 0x00 | '1' -> 0x01 | '2' -> 0x02 | '3' -> 0x03 | '4' -> 0x04
    | '5' -> 0x05 | '6' -> 0x06 | '7' -> 0x07 | '8' -> 0x08 | '9' -> 0x09
    | 'b' -> 0x0a | 'c' -> 0x0b | 'd' -> 0x0c | 'e' -> 0x0d | 'f' -> 0x0e
    | 'g' -> 0x0f | 'h' -> 0x10 | 'j' -> 0x11 | 'k' -> 0x12 | 'm' -> 0x13
    | 'n' -> 0x14 | 'p' -> 0x15 | 'q' -> 0x16 | 'r' -> 0x17 | 's' -> 0x18
    | 't' -> 0x19 | 'u' -> 0x1a | 'v' -> 0x1b | 'w' -> 0x1c | 'x' -> 0x1d
    | 'y' -> 0x1e | 'z' -> 0x1f
    | _   -> 0

  let is_bit_set idx bits =
    0 != bits land (1 lsl idx)

  let rec decode_5bits tmp idx max off bits =
    if idx >= max
    then tmp
    else
      let choose hi minmax =
        let (a,b) = minmax in
        let m = (a +. b) /. 2. in
        if hi
        then (m,b)
        else (a,m)
      in
      let hi = bits |> is_bit_set (4 - idx) in
      let islon = off = (idx mod 2) in
      let (lon,lat) = tmp in
      let tmp' = if islon
        then (lon |> choose hi, lat)
        else (lon             , lat |> choose hi)
      in decode_5bits tmp' (idx + 1) max off bits

  let rec decode_str str idx max tmp =
    if idx >= max
    then tmp
    else idx
      |> String.get str
      |> b32_int_of_char
      |> decode_5bits tmp 0 5 (idx mod 2)
      |> decode_str str (idx + 1) max
 end

let decode str =
  let tmp = P.decode_str str 0 (String.length str) ((-180.,180.),(-90.,90.)) in
  let ((lo0,lo1),(la0,la1)) = tmp in
  (((la0 +. la1) /. 2., (lo0 +. lo1) /. 2.) , (la1 -. la0, lo1 -. lo0))

