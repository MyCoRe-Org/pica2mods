<xsl:stylesheet version="3.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="mods">

    <xsl:import use-when="system-property('XSL_TESTING')='true'" href="picaMode.xsl" />
    <xsl:import use-when="system-property('XSL_TESTING')='true'" href="picaDate.xsl"/>

    <!-- This template is for testing purposes-->
    <xsl:template match="p:record">
        <mods:mods>
            <xsl:call-template name="modsAbstract" />
        </mods:mods>
    </xsl:template>

    <xsl:template name="modsAbstract">
        <xsl:variable name="picaMode">
            <xsl:call-template name="detectPicaMode"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$picaMode = $pica_EPUB">
                <xsl:call-template name="COMMON_ABSTRACT" />
            </xsl:when>
            <xsl:when test="$picaMode = $pica_RDA">

            </xsl:when>
            <xsl:when test="$picaMode = $pica_KXP">
                <xsl:call-template name="COMMON_ABSTRACT" />
            </xsl:when>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="COMMON_ABSTRACT">
        <!--mods:abstract aus 047I mappen und lang-Attribut aus spitzen Klammern am Ende -->
        <xsl:for-each select="./p:datafield[@tag='047I']/p:subfield[@code='a']">
            <mods:abstract type="summary">
                <xsl:choose>
                    <xsl:when test="contains(.,'&lt;ger&gt;')">
                        <xsl:attribute name="lang">ger</xsl:attribute>
                        <xsl:attribute name="xml:lang">de</xsl:attribute>
                        <xsl:value-of select="normalize-space(substring-before(., '&lt;ger&gt;'))" />
                    </xsl:when>
                    <xsl:when test="contains(.,'&lt;eng&gt;')">
                        <xsl:attribute name="lang">eng</xsl:attribute>
                        <xsl:attribute name="xml:lang">en</xsl:attribute>
                        <xsl:value-of select="normalize-space(substring-before(., '&lt;eng&gt;'))" />
                    </xsl:when>
                    <xsl:when test="contains(.,'&lt;spa&gt;')">
                        <xsl:attribute name="lang">spa</xsl:attribute>
                        <xsl:attribute name="xml:lang">es</xsl:attribute>
                        <xsl:value-of select="normalize-space(substring-before(., '&lt;spa&gt;'))" />
                    </xsl:when>
                    <xsl:when test="contains(.,'&lt;fra&gt;')">
                        <xsl:attribute name="lang">fra</xsl:attribute>
                        <xsl:attribute name="xml:lang">fr</xsl:attribute>
                        <xsl:value-of select="normalize-space(substring-before(., '&lt;fra&gt;'))" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="." />
                    </xsl:otherwise>
                </xsl:choose>
            </mods:abstract>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
