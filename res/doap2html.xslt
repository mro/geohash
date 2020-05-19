<?xml version="1.0" encoding="UTF-8"?>
<!--

  Turn DOAP rdf into html.

  Copyright (c) 2013-2020, mro.name/~me Marcus Rohrmoser mobile Software
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted
  provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions
  and the following disclaimer.

  2. The software must not be used for military or intelligence or related purposes nor
  anything that's in conflict with human rights as declared in http://www.un.org/en/documents/udhr/ .

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

  http://www.w3.org/TR/xslt
  http://www.w3.org/TR/xpath/
-->
<xsl:stylesheet
   xmlns:dct="http://purl.org/dc/terms/"
   xmlns:doap="http://usefulinc.com/ns/doap#"
   xmlns:foaf="http://xmlns.com/foaf/0.1/"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns="http://www.w3.org/1999/xhtml"
   xmlns:date="http://exslt.org/date"
   version="1.0">
  <xsl:output
    method="html"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <xsl:variable name="base_url" select="/*/@xml:base"/>

  <xsl:template match="/rdf:RDF">
    <xsl:apply-templates select="doap:Project[1]"/>
  </xsl:template>

  <xsl:template match="doap:Project">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
  <style type="text/css">
/*<![CDATA[*/
  html {
    font-family: sans-serif;
    background:  hsl(30, 50%, 93%);
    color:       hsl(30, 50%, 44%);
  }
  body {
    margin: auto;
    max-width: 43rem;
  }
  a, a:visited {
    color: hsl(115, 50%, 35%);
    text-decoration: none;
  }
  h1 > a, h2 > a {
    font-size:   60%;
    vertical-align: baseline;
    position:   relative;
    top:        -0.7em;
  }
  #sep {
    text-align: center;
  }
  #poweredby {
    font-size:  80%;
    color:      #888;
    border-top: 2px solid darkgrey;
    padding-top: 1ex;
  }
  p[lang="en"]::after { content: "🇬🇧"; }
  pre[lang="en"]::before { content: "🇬🇧"; }
  p[lang="fr"]::after { content: "🇫🇷"; }

  @media (prefers-color-scheme: dark) {
    html {
      background: hsl(30, 20%, 23%);
    }
  }
  /*]]>*/
  </style>

  <title><xsl:value-of select="doap:name"/> – DOAP</title>
</head>

<body>
  <div id="name">
    <h1><xsl:value-of select="doap:name"/><xsl:text> </xsl:text><a href="#name">¶</a></h1>
  </div>

  <div id="shortdesc">
    <xsl:for-each select="doap:shortdesc">
      <p xml:lang="{@xml:lang}" lang="{@xml:lang}">
        <em><xsl:value-of select="."/></em> 
        <!-- sup><a href="http://lexvo.org/id/iso639-1/{@xml:lang}"><xsl:value-of select="@xml:lang"/></a></sup -->
      </p>
    </xsl:for-each>
  </div>

  <div id="description">
     <xsl:for-each select="doap:description">
      <p xml:lang="{@xml:lang}" lang="{@xml:lang}">
        <xsl:value-of select="."/> 
        <!-- sup><a href="http://lexvo.org/id/iso639-1/{@xml:lang}"><xsl:value-of select="@xml:lang"/></a></sup -->
      </p>
    </xsl:for-each>
  </div>

  <ul>
    <xsl:for-each select="doap:readme">
      <li class="readme"><a href="{@rdf:resource}">Readme</a></li>
    </xsl:for-each>

    <xsl:for-each select="doap:homepage">
      <li class="homepage"><a href="{@rdf:resource}">Homepage</a></li>
    </xsl:for-each>

    <xsl:for-each select="doap:mailing-list">
      <li class="mailing-list"><a href="{@rdf:resource}">Mailing List</a></li>
    </xsl:for-each>

    <xsl:for-each select="doap:bug-database">
      <li class="bug-database"><a href="{@rdf:resource}">Bug Database</a></li>
    </xsl:for-each>

    <xsl:for-each select="doap:wiki">
      <li class="wiki"><a href="{@rdf:resource}">Wiki</a></li>
    </xsl:for-each>

    <xsl:for-each select="doap:license">
      <li class="license"><a href="{@rdf:resource}">License</a></li>
    </xsl:for-each>

    <xsl:for-each select="doap:service-endpoint">
      <li class="service-endpoint"><a href="{@rdf:resource}">Service Endpoint</a></li>
    </xsl:for-each>
  </ul>

  <div id="implements">
    <h2>Implements <a href="#implements">¶</a></h2>

    <ul>
      <xsl:for-each select="doap:implements">
        <li class="implements">
          <a href="{@rdf:resource}"><xsl:value-of select="@rdf:resource"/></a>
        </li>
      </xsl:for-each>
    </ul>
  </div>

  <div id="programming-language">
    <h2>Programming Language <a href="#programming-language">¶</a></h2>

    <p>
      <xsl:for-each select="doap:programming-language">
        <span><xsl:value-of select="."/></span>,
      </xsl:for-each>
    </p>
  </div>

  <div id="repositories">
    <h2>Repositories <a href="#repositories">¶</a></h2>

    <ul>
      <xsl:for-each select="doap:repository/*[doap:location]/doap:browse">
        <li>
          <a href="{@rdf:resource}"><xsl:value-of select="@rdf:resource"/></a>
        </li>
      </xsl:for-each>

       <xsl:for-each select="doap:repository/*[not(doap:location)]/doap:browse">
        <li>
          <a href="{@rdf:resource}"><xsl:value-of select="@rdf:resource"/></a>
        </li>
      </xsl:for-each>
    </ul>
  </div>

  <p id="sep">* * *</p>

  <p id="poweredby">RDF (<a href="https://en.wikipedia.org/wiki/DOAP">DOAP</a>): <tt>$ <a href=
  "http://librdf.org/raptor/rapper.html">rapper</a> --guess --output turtle '<span id=
  "my-url">https:// url here</span>'</tt></p><script type="text/javascript">
//<![CDATA[
  document.getElementById('my-url').innerText = location.href;
  //]]>
  </script>
</body>
</html>
  </xsl:template>

</xsl:stylesheet>

