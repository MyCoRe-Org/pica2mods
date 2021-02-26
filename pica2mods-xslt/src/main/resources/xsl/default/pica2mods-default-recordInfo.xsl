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
            <xsl:call-template name="modsRecordInfo" />
        </mods:mods>
    </xsl:template>


    <xsl:template name="modsRecordInfo">
        <xsl:variable name="picaMode">
            <xsl:call-template name="detectPicaMode"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$picaMode = $pica_RDA">
                <mods:recordInfo>
                    <mods:recordIdentifier source="DE-28">
                        <xsl:value-of select="concat('rosdok/ppn',./p:datafield[@tag='003@']/p:subfield[@code='0'])" />
                    </mods:recordIdentifier>
                    <mods:descriptionStandard>rda</mods:descriptionStandard>
                    <mods:recordOrigin><xsl:value-of select="normalize-space(concat('Converted from PICA to MODS using ',$CONVERTER_VERSION))" /></mods:recordOrigin>
                </mods:recordInfo>
            </xsl:when>
            <xsl:when test="$picaMode = $pica_KXP">
                <mods:recordInfo>
                    <mods:recordIdentifier source="DE-28"><xsl:value-of select="concat('rosdok/ppn', ./p:datafield[@tag='003@']/p:subfield[@code='0'])" /></mods:recordIdentifier>
                    <mods:recordOrigin><xsl:value-of select="normalize-space(concat('Converted from PICA to MODS using ',$CONVERTER_VERSION))" /></mods:recordOrigin>
                </mods:recordInfo>
            </xsl:when>
            <xsl:when test="$picaMode = $pica_EPUB">
                <mods:recordInfo>
                    <xsl:for-each select="./p:datafield[@tag='017C']/p:subfield[@code='u']"> <!-- 4950 (kein eigenes Feld) -->
                        <xsl:if test="contains(., '//purl.')">
                            <mods:recordIdentifier source="DE-28">
                                <xsl:value-of select="substring-after(substring(.,9), '/')" />
                            </mods:recordIdentifier>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:for-each select="./p:datafield[@tag='004U']/p:subfield[@code='0']"> <!-- 4950 (kein eigenes Feld) -->
                        <xsl:if test="contains(., 'gbv:519')">
                            <mods:recordIdentifier source="DE-519">
                                dbhsnb/<xsl:value-of select="substring(.,20,string-length(.)-19-2)" />
                            </mods:recordIdentifier>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="./p:datafield[@tag='010E']/p:subfield[@code='e']/text()='rda'">
                        <mods:descriptionStandard>rda</mods:descriptionStandard>
                    </xsl:if>
                    <mods:recordOrigin>
                        <xsl:value-of select="normalize-space(concat('Converted from PICA to MODS using ',$CONVERTER_VERSION))" />
                    </mods:recordOrigin>
                </mods:recordInfo>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>
