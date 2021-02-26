<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsL="http://www.w3.org/1999/XSL/Transform" version="3.0"
                exclude-result-prefixes="mods">

    <xsl:import use-when="system-property('XSL_TESTING')='true'" href="picaMode.xsl" />
    <xsl:import use-when="system-property('XSL_TESTING')='true'" href="picaURLResolver.xsl"/>
    <xsl:import use-when="system-property('XSL_TESTING')='true'" href="picaDate.xsl"/>

    <!-- This template is for testing purposes-->
    <xsl:template match="p:record">
        <mods:mods>
            <xsl:call-template name="modsIdentifier" />
        </mods:mods>
    </xsl:template>

    <xsl:template name="modsIdentifier">
        <xsl:variable name="picaMode">
            <xsl:call-template name="detectPicaMode"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$picaMode = $pica_EPUB">
                <!-- todo: seems like rosdok specific code -->
                <xsl:for-each
                        select="./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(., 'ROSDOK_MD:openaire:')]"> <!-- ISBN einer anderen Ausgabe (z.B. printISBN) -->
                    <mods:identifier type="openaire"> <!-- 2000, ISBN-13 -->
                        <xsl:value-of select="substring(., 20)"/>
                    </mods:identifier>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>

        <xsl:call-template name="COMMON_Identifier" />

    </xsl:template>


    <xsl:template name="COMMON_Identifier">
        <xsl:for-each select="./p:datafield[@tag='017C']/p:subfield[@code='u']">
            <!-- 4950 (kein eigenes Feld) -->
            <mods:identifier type="url">
                    <xsl:value-of select="."/>
                </mods:identifier>
        </xsl:for-each>

        <xsl:for-each select="./p:datafield[@tag='003@']/p:subfield[@code='0']"> <!--  0100 -->
            <mods:identifier type="PPN">
                <xsl:value-of select="."/>
            </mods:identifier>
        </xsl:for-each>
        <xsl:for-each
                select="./p:datafield[@tag='004U']/p:subfield[@code='0']"> <!-- 2050 -->
            <mods:identifier type="urn">
                <xsl:value-of select="."/>
            </mods:identifier>
        </xsl:for-each>
        <xsl:for-each
                select="./p:datafield[@tag='004V']/p:subfield[@code='0']"> <!-- 2051 -->
            <mods:identifier type="doi">
                <xsl:value-of select="."/>
            </mods:identifier>
        </xsl:for-each>
        <xsl:for-each
                select="./p:datafield[@tag='004P' or @tag='004A' or @tag='004J']/p:subfield[@code='0']"> <!-- ISBN, ISBN einer anderen phys. Form (z.B. printISBN), ISBN der Reproduktion -->
            <mods:identifier type="isbn"> <!-- 200x, ISBN-13 -->
                <xsl:value-of select="."/>
            </mods:identifier>
        </xsl:for-each>

        <!--  alle VD-Nummern werden OHNE Präfix VDxx ins MODS übertragen -->
        <xsl:for-each select="./p:datafield[@tag='006V']"> <!--  2190 -->
            <xsl:choose>
                <xsl:when test="starts-with(./p:subfield[@code='0'],'VD')">
                    <mods:identifier type="vd16">
                        <xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], '16'))"/>
                    </mods:identifier>
                </xsl:when>
                <xsl:otherwise>
                    <mods:identifier type="vd16">
                        <xsl:value-of select="./p:subfield[@code='0']"/>
                    </mods:identifier>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="./p:datafield[@tag='006W']"> <!--  2191 -->
            <xsl:choose>
                <xsl:when test="starts-with(./p:subfield[@code='0'],'VD')">
                    <mods:identifier type="vd17">
                        <xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], '17'))"/>
                    </mods:identifier>
                </xsl:when>
                <xsl:otherwise>
                    <mods:identifier type="vd17">
                        <xsl:value-of select="./p:subfield[@code='0']"/>
                    </mods:identifier>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="./p:datafield[@tag='006M']"> <!--  2192 -->
            <xsl:choose>
                <xsl:when test="starts-with(./p:subfield[@code='0'],'VD')">
                    <mods:identifier type="vd18">
                        <xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], '18'))"/>
                    </mods:identifier>
                </xsl:when>
                <xsl:otherwise>
                    <mods:identifier type="vd18">
                        <xsl:value-of select="./p:subfield[@code='0']"/>
                    </mods:identifier>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="./p:datafield[@tag='006Z']"> <!--  2110 -->
            <mods:identifier type="zdb">
                <xsl:value-of select="./p:subfield[@code='0']"/>
            </mods:identifier>
        </xsl:for-each>
        <xsl:for-each select="./p:datafield[@tag='007S']"><!-- 2277 -->
            <xsl:choose>
                <!-- VD16 nicht nur in 2190, sondern als bibliogr. Zitat in 2277 -->
                <xsl:when
                        test="starts-with(./p:subfield[@code='0'], 'VD16') or starts-with(./p:subfield[@code='0'], 'VD 16')">
                    <xsl:if test="not(./../p:datafield[@tag='006V'])">
                        <mods:identifier type="vd16">
                            <xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], '16'))"/>
                        </mods:identifier>
                    </xsl:if>
                </xsl:when>
                <!-- VD17 nicht nur in 2191, sondern als bibliogr. Zitat in 2277 -->
                <xsl:when
                        test="starts-with(./p:subfield[@code='0'], 'VD17') or starts-with(./p:subfield[@code='0'], 'VD 17')">
                    <xsl:if test="not(./../p:datafield[@tag='006W'])">
                        <mods:identifier type="vd17">
                            <xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], '17'))"/>
                        </mods:identifier>
                    </xsl:if>
                </xsl:when>
                <!--VD18 nicht nur in 2192, sondern als bibliogr. Zitat in 2277 -->
                <xsl:when
                        test="starts-with(./p:subfield[@code='0'], 'VD18') or starts-with(./p:subfield[@code='0'], 'VD 18')">
                    <xsl:if test="not(./../p:datafield[@tag='006M'])">
                        <mods:identifier type="vd18">
                            <xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], '18'))"/>
                        </mods:identifier>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="starts-with(./p:subfield[@code='0'], 'RISM')">
                    <mods:identifier type="rism">
                        <xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], 'RISM'))"/>
                    </mods:identifier>
                </xsl:when>
                <xsl:when test="starts-with(./p:subfield[@code='0'], 'Kalliope')">
                    <mods:identifier type="kalliope">
                        <xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], 'Kalliope'))"/>
                    </mods:identifier>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="not(./p:subfield[@code='S']='e')">
                        <mods:note type="bibliographic_reference">
                            <xsl:value-of select="./p:subfield[@code='0']"/>
                        </mods:note>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
