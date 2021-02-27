<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="3.0"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
                exclude-result-prefixes="mods pica2mods">

    <xsl:import use-when="system-property('XSL_TESTING')='true'" href="_common/pica2mods-functions.xsl"/>
    
    <!-- This template is for testing purposes-->
    <xsl:template match="p:record">
        <mods:mods>
            <xsl:call-template name="modsGenre" />
        </mods:mods>
    </xsl:template>

    <xsl:template name="modsGenre">
        <xsl:variable name="picaMode" select="pica2mods:detectPicaMode(.)" />
        <xsl:variable name="pica0500_2" select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)"/>

        <xsl:choose>
            <xsl:when test="$picaMode = 'RDA'">
                <xsl:if test="not($pica0500_2='v')">
                    <xsl:variable name="ppnA" select="./p:datafield[@tag='039I']/p:subfield[@code='9'][1]/text()"/>
                    <xsl:variable name="zdbA"
                                  select="./p:datafield[@tag='039I']/p:subfield[@code='C' and text()='ZDB']/following-sibling::p:subfield[@code='6'][1]/text()"/>
                   <!--  TODO move to function -->
                   <xsl:variable name="picaA">
                            <xsl:choose>
                                <xsl:when test="$ppnA">
                                    <xsl:value-of select="pica2mods:queryPicaFromSRUWithQuery('k10plus', concat('pica.ppn=', $ppnA))"/>
                                </xsl:when>
                                <xsl:when test="$zdbA">
                                    <xsl:value-of select="pica2mods:queryPicaFromSRUWithQuery('k10plus', concat('pica.zdb=', $zdbA))"/>
                                </xsl:when>
                            </xsl:choose>
                    </xsl:variable>
                    <xsl:for-each
                            select="$picaA/p:datafield[@tag='044S']"> <!-- 5570 Gattungsbegriffe AAD, RDA aus A-Aufnahme -->
                        <mods:genre type="aadgenre">
                            <xsl:value-of select="./p:subfield[@code='a']"/>
                        </mods:genre>
                        <!--  <xsl:call-template name="COMMON_UBR_Class_AADGenres"/> -->
                    </xsl:for-each>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$picaMode = 'KXP'">
                <xsl:for-each select="./p:datafield[@tag='044S']"> <!-- 5570 Gattungsbegriffe AAD -->
                    <mods:genre type="aadgenre"><xsl:value-of select="./p:subfield[@code='a']"/></mods:genre>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$picaMode = 'EPUB'">

            </xsl:when>

        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>
