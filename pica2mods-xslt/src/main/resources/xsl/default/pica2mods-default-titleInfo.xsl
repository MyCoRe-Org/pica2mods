<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="3.0"
                exclude-result-prefixes="mods">

    <xsl:import use-when="system-property('XSL_TESTING')='true'" href="picaMode.xsl" />
    <xsl:import use-when="system-property('XSL_TESTING')='true'" href="picaURLResolver.xsl"/>
    <xsl:import use-when="system-property('XSL_TESTING')='true'" href="picaDate.xsl"/>

    <!-- This template is for testing purposes-->
    <xsl:template match="p:record">
        <mods:mods>
            <xsl:call-template name="modsTitleInfo" />
        </mods:mods>
    </xsl:template>



    <xsl:template name="modsTitleInfo">
        <xsl:variable name="picaMode">
            <xsl:call-template name="detectPicaMode" />
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$picaMode = $pica_EPUB">
                <xsl:choose>
                    <!-- code from ubr_pica2mods_EPUB.xsl -->
                    <xsl:when test="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)='f' or substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)='F' ">
                        <xsl:for-each select="./p:datafield[@tag='036C']">
                            <xsl:call-template name="COMMON_Title" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when
                            test="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)='v' and ./p:datafield[@tag='027D']">
                        <xsl:for-each select="./p:datafield[@tag='027D']">
                            <xsl:call-template name="COMMON_Title"/>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="./p:datafield[@tag='021A']">
                            <xsl:call-template name="COMMON_Title"/>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$picaMode = $pica_KXP or $picaMode = $pica_RDA">
                <!-- code from ubr_pica2mods_KXP.xsl and ubr_pica2mods_RDA-->
                <xsl:variable name="pica0500_2" select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
                <xsl:choose>
                    <xsl:when test="$pica0500_2='f' or $pica0500_2='F' ">
                        <xsl:for-each select="./p:datafield[@tag='036C']"><!-- 4150 -->
                            <xsl:call-template name="COMMON_Title" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="$pica0500_2='v' and ./p:datafield[@tag='036F']">
                        <xsl:for-each select="./p:datafield[@tag='036F']"><!-- 4180 -->
                            <xsl:call-template name="COMMON_Title" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="./p:datafield[@tag='021A']"> <!-- 4000 -->
                            <xsl:call-template name="COMMON_Title" />
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="COMMON_Alt_Uniform_Title" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="COMMON_Title">
        <mods:titleInfo>
            <xsl:attribute name="usage">primary</xsl:attribute>
            <xsl:if test="./p:subfield[@code='a']">
                <xsl:variable name="mainTitle" select="./p:subfield[@code='a']"/>
                <xsl:choose>
                    <xsl:when test="contains($mainTitle, '@')">
                        <xsl:variable name="nonSort" select="normalize-space(substring-before($mainTitle, '@'))"/>
                        <xsl:choose>
                            <!-- nonSort this should be deadCode-->
                            <xsl:when test="string-length(nonSort) &lt; 9">
                                <mods:nonSort>
                                    <xsl:value-of select="$nonSort"/>
                                </mods:nonSort>
                                <mods:title>
                                    <xsl:value-of select="substring-after($mainTitle, '@')"/>
                                </mods:title>
                            </xsl:when>
                            <xsl:otherwise>
                                <mods:title>
                                    <xsl:value-of select="$mainTitle"/>
                                </mods:title>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <mods:title>
                            <xsl:value-of select="$mainTitle"/>
                        </mods:title>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>

            <xsl:if test="./p:subfield[@code='d']">
                <mods:subTitle>
                    <xsl:value-of select="./p:subfield[@code='d']"/>
                </mods:subTitle>
            </xsl:if>

            <!-- nur in fingierten Titel 036C / 4150 -->
            <xsl:if test="./p:subfield[@code='y']">
                <mods:subTitle>
                    <xsl:value-of select="./p:subfield[@code='y']"/>
                </mods:subTitle>
            </xsl:if>

            <xsl:if test="./p:subfield[@code='l']">
                <mods:partNumber>
                    <xsl:value-of select="./p:subfield[@code='l']"/>
                </mods:partNumber>
            </xsl:if>
            <xsl:if test="./@tag='036C' and not(./p:subfield[@code='l']) and ./../p:datafield[@tag='036D']/p:subfield[@code='l']">
                <mods:partNumber>
                    <xsl:value-of select="./../p:datafield[@tag='036D']/p:subfield[@code='l']"/>
                </mods:partNumber>
            </xsl:if>

            <xsl:if test="(@tag='036C' or @tag='036F') and ./../p:datafield[@tag='021A']">
                <xsl:variable name="out">
                    <xsl:value-of select="translate(./../p:datafield[@tag='021A']/p:subfield[@code='a'], '@', '')"/>
                    <xsl:if test="./../p:datafield[@tag='021A']/p:subfield[@code='d']">
                        :
                        <xsl:value-of select="./../p:datafield[@tag='021A']/p:subfield[@code='d']"/>
                    </xsl:if>
                </xsl:variable>
                <mods:partName>
                    <xsl:value-of select="normalize-space($out)"></xsl:value-of>
                </mods:partName>
            </xsl:if>
        </mods:titleInfo>
    </xsl:template>


    <xsl:template name="COMMON_Alt_Uniform_Title">
        <!-- 3260/027A$a abweichender Titel,
           4212/046C abweichender Titel,
           4213/046D früherere Hauptitel
           4002/021F Paralleltitel,
           4000/021A$f Paralleltitel (RAK),

           3210/022A Werktitel,
           3232/026C Zeitschriftenkurztitel -->
        <xsl:for-each select="./p:datafield[@tag='027A' or @tag='021F' or @tag='046C' or @tag='046D']/p:subfield[@code='a'] | ./p:datafield[@tag='021A']/p:subfield[@code='f'] ">
            <mods:titleInfo type="alternative">
                <mods:title>
                    <xsl:if test="./../p:subfield[@code='i']"><xsl:value-of select="./../p:subfield[@code='i']" />: </xsl:if>
                    <xsl:value-of select="translate(., '@', '')" /></mods:title>
            </mods:titleInfo>
        </xsl:for-each>
        <xsl:for-each select="./p:datafield[@tag='022A']">
            <mods:titleInfo type="uniform">
                <mods:title><xsl:value-of select="translate(./p:subfield[@code='a'], '@', '')" /></mods:title>
            </mods:titleInfo>
        </xsl:for-each>
        <xsl:for-each select="./p:datafield[@tag='026C']">
            <mods:titleInfo type="abbreviated">
                <mods:title><xsl:value-of select="translate(./p:subfield[@code='a'], '@', '')" /></mods:title>
            </mods:titleInfo>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
