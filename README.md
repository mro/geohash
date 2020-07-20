
# geohash

Convert WGS84 lat/lon pairs to [Gustavo Niemeyer](http://niemeyer.net/)s
[Geohash](http://en.wikipedia.org/wiki/Geohash) and back. Web and commandline, 🐪,
statically linked, single-file, zero-config.

See also

* https://tools.ietf.org/html/rfc5870
* https://github.com/francoisroyer/ocaml-geohash
* https://github.com/mariusae/ocaml-geohash
* https://github.com/gansidui/geohash/blob/master/geohash.go#L50

## Install / Update

If the webserver is Apache (Linux 64 bit, set up and running, module cgi enabled):

1. Download http://purl.mro.name/Linux-x86_64/geohash.cgi,
2. copy this single file to your webspace,
3. set it's file permissions (chmod) to numeric 555 (readonly + executable for all),
4. visit in your browser: http://my.web.space/subdir/geohash.cgi,

done!

## Design Goals

| Quality         | very good | good | normal | irrelevant |
|-----------------|:---------:|:----:|:------:|:----------:|
| Functionality   |           |      |    ×   |            |
| Reliability     |     ×     |      |        |            |
| Usability       |           |   ×  |        |            |
| Efficiency      |     ×     |      |        |            |
| Changeability   |           |   ×  |        |            |
| Portability     |           |      |    ×   |            |

## Mirrors

see doap.rdf
