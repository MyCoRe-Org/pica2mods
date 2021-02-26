<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsL="http://www.w3.org/1999/XSL/Transform" version="3.0"
                exclude-result-prefixes="mods">

    <xsl:import use-when="system-property('XSL_TESTING')='true'" href="picaMode.xsl" />
    <xsl:import use-when="system-property('XSL_TESTING')='true'" href="picaDate.xsl"/>

    <!-- This template is for testing purposes-->
    <xsl:template match="p:record">
        <mods:mods>
            <xsl:call-template name="modsLanguage" />
        </mods:mods>
    </xsl:template>

    <xsl:template name="modsLanguage">
        <xsl:variable name="picaMode">
            <xsl:call-template name="detectPicaMode"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$picaMode = $pica_EPUB or $picaMode = $pica_KXP or $picaMode = $pica_RDA">
                <xsl:for-each select="./p:datafield[@tag='010@']"> <!-- 1500 Language -->
                    <!-- weiter Unterfelder für Orginaltext / Zwischenübersetzung nicht abbildbar -->
                    <xsl:for-each select="./p:subfield[@code='a']">
                        <mods:language>
                            <mods:languageTerm type="code" authority="iso639-2b">
                                <xsl:value-of select="."/>
                            </mods:languageTerm>
                        </mods:language>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>
