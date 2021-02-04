<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsL="http://www.w3.org/1999/XSL/Transform" version="3.0"
                exclude-result-prefixes="mods">


    <xsl:template name="modsNote">
        <xsl:variable name="picaMode">
            <xsl:call-template name="detectPicaMode"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$picaMode = $pica_RDA">

            </xsl:when>
            <xsl:when test="$picaMode = $pica_KXP">

            </xsl:when>
            <xsl:when test="$picaMode = $pica_EPUB">

            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
