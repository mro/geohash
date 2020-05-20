<?xml version="1.0" encoding="UTF-8"?>
<!--
  geohash
  Copyright (C) 2020-2020  Marcus Rohrmoser, http://purl.mro.name/geohash

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

  <xsl:variable name="dlon" select="0.5"/>
  <xsl:variable name="dlat" select="0.5"/>
  <xsl:variable name="zoom" select="10"/>

  <xsl:variable name="globe">🌐</xsl:variable>
  <xsl:variable name="camel">🐫</xsl:variable>

  <xsl:output
    method="html"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <xsl:template match="/">
    <xsl:apply-templates select="g:gpx"/>
  </xsl:template>

  <xsl:template match="g:gpx">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="head"/>

      <xsl:variable name="wpt" select="g:wpt[1]"/>

      <body>
        <form action=".." id="search_form" name="search_form">
          <span>Location</span>
          <xsl:text> </xsl:text>
          <input name="q" placeholder="lat lon" size="30" value="{$wpt/@lat},{$wpt/@lon}" autofocus="autofocus" />
          <xsl:text> </xsl:text>
<!-- 
          <span>Target URL</span>
          <input name="redir" size="60" placeholder="https://www.openstreetmap.org/?mlat={lat}&amp;mlon={lon}#map={zoom}/{lat}/{lon}">
            <xsl:attribute name="value">https://www.openstreetmap.org/?mlat={lat}&amp;mlon={lon}#map={zoom}/{lat}/{lon}</xsl:attribute> 
          </input>
          <xsl:text> </xsl:text>
-->
          <button type="submit">Go</button>
        </form>

        <p id="standalone">
          <small>
            <xsl:variable name="mapurl">
              https://www.openstreetmap.org/?mlat=<xsl:value-of select="$wpt/@lat"/>&amp;mlon=<xsl:value-of select="$wpt/@lon"/>
            </xsl:variable>
            <a href="{$mapurl}"><xsl:value-of select="$mapurl"/></a>
          </small>
        </p>
        <iframe scrolling="no" marginheight="0" marginwidth="0"
          src="https://www.openstreetmap.org/export/embed.html?bbox={$wpt/@lon - $dlon},{$wpt/@lat - $dlat},{$wpt/@lon + $dlon},{$wpt/@lat + $dlat}&amp;marker={$wpt/@lat},{$wpt/@lon}"
          style="width:100%;height:calc(97vh - var(--form-height) - 12ex - 8px)"/>

        <p id="credits">
          Powered by <a href="../about">http://purl.mro.name/geohash <xsl:value-of select="$camel"/></a>
        </p>
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
    --form-height: 4ex;
  }
  form#search_form {
    width:100%;
    height:var(--form-height);
  }
  /*]]>*/      </style>
    </head>
  </xsl:template>
</xsl:stylesheet>

