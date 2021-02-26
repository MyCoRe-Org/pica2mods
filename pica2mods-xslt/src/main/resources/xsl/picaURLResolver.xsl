<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="3.0">

    <xsl:param name="MCR.SRU.URL" select="'http://sru.k10plus.de'"/>
    <xsl:param name="MCR.UNAPI.URL" select="'http://unapi.k10plus.de'"/>

    <xsl:param name="MCR.PICA.DATABASE.k10plus" select="'k10plus'"/>

    <xsl:template name="retrieveXMLViaSru">
        <xsl:param name="sruQuery"/>
        <xsl:param name="database"/>

        <xsl:variable name="encodedSruQuery" select="encode-for-uri($sruQuery)"/>
        <xsl:variable name="requestURL" select="concat($MCR.SRU.URL, '/', $database,'/',
        '?operation=searchRetrieve&amp;maximumRecords=1&amp;recordSchema=picaxml&amp;query=',
        $encodedSruQuery)"/>
        <xsl:copy-of select="document($requestURL)" />
    </xsl:template>

    <xsl:template name="retrieveXMLViaUnapi">
        <xsl:param name="unApiID"/>

        <xsl:variable name="requestURL" select="concat($MCR.UNAPI.URL,'/', '?format=picaxml&amp;id=', $unApiID)" />
        <xsl:copy-of select="document($requestURL)" />
    </xsl:template>
</xsl:stylesheet>
