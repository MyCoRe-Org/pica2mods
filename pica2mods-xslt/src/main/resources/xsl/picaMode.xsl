<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
                version="3.0">


    <xsl:variable name="pica_EPUB" select="'EPUB'"/>
    <xsl:variable name="pica_KXP" select="'KXP'"/>
    <xsl:variable name="pica_RDA" select="'RDA'"/>

    <xsl:template name="detectPicaMode">
        <xsl:choose>
            <xsl:when test="./p:datafield[@tag='209O']/p:subfield[@code='a' and contains(.,':doctype:epub')]">
                <xsl:value-of select="$pica_EPUB" />
            </xsl:when>
            <xsl:when test="./p:datafield[@tag='007G']/p:subfield[@code='i']/text()='KXP'">
                <xsl:value-of select="$pica_KXP" />
            </xsl:when>
            <xsl:when
                    test="not(./p:datafield[@tag='011B']) and ./p:datafield[@tag='010E']/p:subfield[@code='e']/text()='rda'">
                <xsl:value-of select="$pica_RDA" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$pica_KXP" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
