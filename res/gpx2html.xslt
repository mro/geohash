<?xml version="1.0" encoding="UTF-8"?>
<!--
  geohash
  Copyright (c) 2020-2021 Marcus Rohrmoser mobile Software http://mro.name/~me. All rights reserved.

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  https://www.w3.org/TR/xslt-10/
-->
<xsl:stylesheet
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:g="http://www.topografix.com/GPX/1/1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="g"
  version="1.0">

  <xsl:variable name="dlon" select="0.3"/>
  <xsl:variable name="dlat" select="0.3"/>
  <xsl:variable name="zoom" select="11"/>

  <xsl:variable name="pin">📍</xsl:variable>
  <xsl:variable name="globe">🌐</xsl:variable>
  <xsl:variable name="camel">🐫</xsl:variable>

  <xsl:output
    method="html"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <xsl:variable name="Geo2Rdf">
    <!--
      bookmarklet to conveniently pick geo coordinates from OSM/Google Maps.
      http://heimat.mro.name/bayern/allgaeu/steiner1994/#
    -->
    <![CDATA[ javascript:(
function(bas)
{
  /* selection has highest precendence: */
  var sel = null;
  if (window.getSelection) {
    sel = window.getSelection();
  } else if (document.getSelection) {
    sel = document.getSelection();
  } else if (document.selection) {
    sel = document.selection.createRange().text;
  }
  var tocheck = new Array();
  if(sel)
    tocheck.push(sel.toString());
  /* also test #link/@href (that's how google maps, share link does it. */
  sel = document.getElementById('link');
  if(sel && sel.href)
    tocheck.push(sel.href);
  /* last, not least, document location: */
  tocheck.push(document.location.href);
  /* patterns to test: */
  var pattern = [
    /#map=(?:[0-9]+)\/(-?[0-9.]+)\/(-?[0-9.]+)/, /* http://openstreetmap.org/ */
    /[?&]lat=(-?[0-9.]+)[?&]lon=(-?[0-9.]+)/, /* http://openstreetmap.de/ */
    /[?&]lon=(-?[0-9.]+)[?&]lat=(-?[0-9.]+)/, /* http://openstreetmap.de/ */
    /maps\/.*?@(-?[0-9.]+),(-?[0-9.]+),[0-9]+z/, /* https://maps.google.de/ */
    /[?&]ll=(-?[0-9.]+),(-?[0-9.]+)/, /* https://maps.google.com/ */
  ];
  for(var k=0;k<tocheck.length;k++) {
    var href = tocheck[k];
    for(var i=0;i<pattern.length;i++) {
      var m = href.match(pattern[i]);
      if(m) {
        var latlon = m[1] + ',' + m[2];
        window.prompt('#🌐 Geohash',bas+'?q='+latlon);
        /* window.location.href = bas+'?q='+latlon; */
        return;
      }
    }
  }
  window.alert('No coord found in '+bas);
}('../')); ]]>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates select="g:gpx"/>
  </xsl:template>

  <xsl:template match="g:gpx">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="head"/>

      <xsl:variable name="bbox" select="g:metadata/g:bounds"/>
      <xsl:variable name="wpt" select="g:wpt[1]"/>

      <body>
        <iframe src="https://www.openstreetmap.org/export/embed.html?bbox={$bbox/@minlon},{$bbox/@minlat},{$bbox/@maxlon},{$bbox/@maxlat}&amp;marker={$wpt/@lat},{$wpt/@lon}"/>

        <form action="." id="search_form" name="search_form">
          <input name="q" placeholder="lat lon or geo:lat,lon" size="20" value="{$wpt/@lat},{$wpt/@lon}" autofocus="autofocus" />
<!-- 
          <span>Target URL</span>
          <input name="redir" size="60" placeholder="https://www.openstreetmap.org/?mlat={lat}&amp;mlon={lon}#map={zoom}/{lat}/{lon}">
            <xsl:attribute name="value">https://www.openstreetmap.org/?mlat={lat}&amp;mlon={lon}#map={zoom}/{lat}/{lon}</xsl:attribute> 
          </input>
          <xsl:text> </xsl:text>
-->
          <button type="submit">Go</button>

          <small id="standalone">
            <xsl:value-of select="$globe"/>
            <xsl:variable name="mapurl">
              https://www.openstreetmap.org/?mlat=<xsl:value-of select="$wpt/@lat"/>&amp;mlon=<xsl:value-of select="$wpt/@lon"/>
            </xsl:variable>
            <a href="{$mapurl}"><xsl:value-of select="$mapurl"/></a>
          </small>
          <xsl:text> </xsl:text>
          <small id="credits">Powered by <a href="./about">http://purl.mro.name/geohash <xsl:value-of select="$camel"/></a></small>
          <xsl:text> </xsl:text>
          <small>
            <a id="bookmarklet" href="{$Geo2Rdf}"><xsl:value-of select="$globe"/> Geohash Bookmarklet</a>
            <script>
/* MIT License https://github.com/joliss/js-string-escape/blob/master/index.js */
function jsStringEscape(string) {
  return ('' + string).replace(/["'\\\n\r\u2028\u2029]/g, function (character) {
    // Escape all characters not included in SingleStringCharacters and
    // DoubleStringCharacters on
    // http://www.ecma-international.org/ecma-262/5.1/#sec-7.8.4
    switch (character) {
      case '"':
      case "'":
      case '\\':
        return '\\' + character
      // Four possible LineTerminator characters need to be escaped:
      case '\n':
        return '\\n'
      case '\r':
        return '\\r'
      case '\u2028':
        return '\\u2028'
      case '\u2029':
        return '\\u2029'
    }
  })
}
              var a = document.getElementById("bookmarklet");
              a.href = a.href.replace("}('../'));", "}('"+jsStringEscape(window.location)+"/../'));");
            </script>
          </small>
        </form>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="head">
    <head>
      <meta content="text/html; charset=utf-8" http-equiv="content-type"/>
      <!-- https://developer.apple.com/library/IOS/documentation/AppleApplications/Reference/SafariWebContent/UsingtheViewport/UsingtheViewport.html#//apple_ref/doc/uid/TP40006509-SW26 -->
      <!-- http://maddesigns.de/meta-viewport-1817.html -->
      <!-- meta name="viewport" content="width=device-width"/ -->
      <!-- http://www.quirksmode.org/blog/archives/2013/10/initialscale1_m.html -->
      <meta name="viewport" content="width=device-width,initial-scale=1.0"/>

      <title>#<xsl:value-of select="$globe"/> Geohash</title>
      <style type="text/css">
/*<![CDATA[*/
  body {
    margin: 0;
  }
  iframe {
    border:0;
    height:100%;
    position:fixed; /* https://stackoverflow.com/a/2425694/349514 */
    width:100%;
  }
  form {
    left: 58px;
    line-height: 4ex;
    position: absolute;
    top: 4px;
    width: calc(100% - 59px);
  }
  input {
    background: white;
  }
  small {
    /* https://alligator.io/css/prevent-line-break/ */
    background-color: hsla(0,0%,100%,0.75);
    border: 2px solid #ccc;
    overflow: hidden;
    padding: 1.1ex;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  input,button {
    font-family: monospace;
    font-size: 10pt;
    padding: 0.8ex 1.5ex;
  }
  input,button,small {
    border-radius: 1ex;
    margin: 1.2ex;
  }
  /*]]>*/      </style>
    </head>
  </xsl:template>
</xsl:stylesheet>
