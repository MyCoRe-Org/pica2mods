<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="3.0"
                exclude-result-prefixes="mods">

    <xsl:mode on-no-match="deep-copy"/>

    <xsl:template match="/">
        <html>
            <head>
                <title>Test - Result</title>
                <style>
                    .compare {
                        width: 47%;
                        display: inline-block;
                    }
                </style>
                <link rel="stylesheet"
                      href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.5.0/styles/default.min.css" />
                <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.5.0/highlight.min.js"></script>
                <script>hljs.initHighlightingOnLoad();</script>

            </head>
            <body>
                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="result">
        <h1>Test - Results</h1>

        <ol>
            <xsl:for-each select="compare">
                <xsl:variable name="ppn" select="@ppn"/>
                <li>
                    <a href="#ppn_{$ppn}">
                        <xsl:value-of select="@ppn"/>
                    </a>
                </li>
                <ol>
                    <xsl:for-each select="tle">
                        <li>
                            <a href="#ppn_{$ppn}_{@name}">
                                <xsl:value-of select="@name"/>
                            </a>
                        </li>
                    </xsl:for-each>
                </ol>
            </xsl:for-each>
        </ol>
        <xsl:for-each select="compare">
            <xsl:variable name="ppn" select="@ppn"/>
            <h2 id="ppn_{$ppn}">
                <xsl:value-of select="$ppn"/>
            </h2>
            <xsl:for-each select="tle">
                <h3 id="ppn_{$ppn}_{@name}">
                    <xsl:value-of select="@name"/>
                </h3>
                <pre class="compare"><code class="xml left">
                    <xsl:value-of select="transformed"/>
                </code></pre>
                <pre class="compare"><code class="xml right">
                    <xsl:value-of select="expected"/>
                </code></pre>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
