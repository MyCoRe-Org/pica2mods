<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsL="http://www.w3.org/1999/XSL/Transform" version="3.0"
                exclude-result-prefixes="mods">


    <xsl:template name="modsGenre">
        <xsl:variable name="picaMode">
            <xsl:call-template name="detectPicaMode"/>
        </xsl:variable>
        <xsl:variable name="pica0500_2" select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)"/>

        <xsl:choose>

            <xsl:when test="$picaMode = $pica_RDA">
                <xsl:if test="not($pica0500_2='v')">
                    <xsl:variable name="ppnA" select="./p:datafield[@tag='039I']/p:subfield[@code='9'][1]/text()"/>
                    <xsl:variable name="zdbA"
                                  select="./p:datafield[@tag='039I']/p:subfield[@code='C' and text()='ZDB']/following-sibling::p:subfield[@code='6'][1]/text()"/>
                    <xsl:variable name="query">
                        <xsl:choose>
                            <xsl:when test="$ppnA">
                                <xsl:value-of select="concat('sru-k10plus:pica.ppn=', $ppnA)"/>
                            </xsl:when>
                            <xsl:when test="$zdbA">
                                <xsl:value-of select="concat('sru-k10plus:pica.zdb=', $zdbA)"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="picaA" select="document($query)"/>
                    <xsl:for-each
                            select="$picaA/p:record/p:datafield[@tag='044S']"> <!-- 5570 Gattungsbegriffe AAD, RDA aus A-Aufnahme -->
                        <mods:genre type="aadgenre">
                            <xsl:value-of select="./p:subfield[@code='a']"/>
                        </mods:genre>
                       <!--  <xsl:call-template name="COMMON_UBR_Class_AADGenres"/> -->
                    </xsl:for-each>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$picaMode = $pica_KXP">
                <xsl:for-each select="./p:datafield[@tag='044S']"> <!-- 5570 Gattungsbegriffe AAD -->
                    <mods:genre type="aadgenre"><xsl:value-of select="./p:subfield[@code='a']"/></mods:genre>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$picaMode = $pica_EPUB">

            </xsl:when>

        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>
