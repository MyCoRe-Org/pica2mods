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
                <xsl:call-template name="common_source_note"/>
                <xsl:call-template name="common_reproduction_note"/>
                <xsl:call-template name="common_titleword_index"/>
            </xsl:when>
            <xsl:when test="$picaMode = $pica_KXP">
                <xsl:call-template name="common_source_note"/>
                <xsl:call-template name="common_reproduction_note"/>
                <xsl:call-template name="common_titleword_index"/>
            </xsl:when>
            <xsl:when test="$picaMode = $pica_EPUB">
                <xsl:for-each select="./p:datafield[@tag='037A']"><!-- Gutachter in Anmerkungen -->
                    <xsl:choose>
                        <xsl:when test="starts-with(./p:subfield[@code='a'], 'GutachterInnen:')">
                            <mods:note type="referee">
                                <xsl:value-of select="substring-after(./p:subfield[@code='a'], 'GutachterInnen: ')" />
                            </mods:note>
                        </xsl:when>
                        <xsl:otherwise>
                            <mods:note type="other">
                                <xsl:value-of select="./p:subfield[@code='a']" />
                            </mods:note>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>

                <xsl:for-each select="./p:datafield[@tag='037B' or @tag='046L' or @tag='046F' or @tag='046G' or @tag='046H' or @tag='046I']"><!-- 4201, 4202, 4221, 4215, 4216, 4217, 4218 RDA raus 4202, 4215, 4216 neu 4210, 4212, 4221, 4223, 4226 (einfach den ganzen Anmerkungskrams mitnehmen" -->
                    <mods:note type="other">
                        <xsl:value-of select="./p:subfield[@code='a']" />
                    </mods:note>
                </xsl:for-each>

                <xsl:for-each select="./p:datafield[@tag='047C' or @tag='022A']">
                    <!-- 4200 (047C, abweichende Sucheinstiege, RDA zusätzlich:3210 (022A, Werktitel) und 3260 (027A, abweichender Titel) -->
                    <mods:note type="titlewordindex">
                        <xsl:value-of select="./p:subfield[@code='a']" />
                    </mods:note>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>

        <xsl:call-template name="common_statement_of_responsibility"/>
    </xsl:template>

    <xsl:template name="common_statement_of_responsibility">
        <xsl:if test="./p:datafield[@tag='021A']/p:subfield[@code='h']">
            <mods:note type="statement of responsibility">
                <xsl:value-of select="./p:datafield[@tag='021A']/p:subfield[@code='h']"/>
            </mods:note>
        </xsl:if>
    </xsl:template>

    <xsl:template name="common_titleword_index">
        <xsl:for-each select="./p:datafield[@tag='047C']">
            <mods:note type="titlewordindex">
                <xsl:value-of select="./p:subfield[@code='a']"/>
            </mods:note>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="common_reproduction_note">
        <xsl:for-each select="./p:datafield[@tag='037G']"> <!-- 4237 Anmerkungen zur Reproduktion -->
            <mods:note type="reproduction">
                <xsl:value-of select="./p:subfield[@code='a']"/>
            </mods:note>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="common_source_note">
        <xsl:for-each select="./p:datafield[@tag='017H']"> <!-- 4961 URL für sonstige Angaben zur Resource -->
            <mods:note type="source note">
                <xsl:attribute name="xlink:href">
                    <xsl:value-of select="./p:subfield[@code='u']"/>
                </xsl:attribute>
                <xsl:value-of select="./p:subfield[@code='y']"/>
            </mods:note>
        </xsl:for-each>
        <xsl:for-each select="./p:datafield[@tag='037A' or @tag='037B' or @tag='046L' or @tag='046F' or @tag='046G' or @tag='046H' or @tag='046I' or @tag='046P']"><!-- 4201, 4202, 4221, 4215, 4216, 4217, 4218 RDA raus 4202, 4215, 4216 neu 4210, 4212, 4221, 4223, 4225, 4226 (einfach den ganzen Anmerkungskrams mitnehmen)" -->
            <mods:note type="source note"><xsl:value-of select="./p:subfield[@code='a']" /></mods:note>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
