<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsL="http://www.w3.org/1999/XSL/Transform" version="3.0"
                exclude-result-prefixes="mods">


    <xsl:import href="picaMode.xsl"/>
    <xsl:import href="picaURLResolver.xsl"/>
    <xsl:import href="picaDate.xsl"/>

    <!-- This template is for testing purposes-->
    <xsl:template match="p:record">
        <mods:mods>
            <xsl:call-template name="modsPhysicalDescription" />
        </mods:mods>
    </xsl:template>

    <xsl:template name="modsPhysicalDescription">
        <xsl:variable name="picaMode">
            <xsl:call-template name="detectPicaMode"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$picaMode = $pica_EPUB">
                <xsl:call-template name="modsPhysicalDescriptionEpub"/>
            </xsl:when>
            <xsl:when test="$picaMode = $pica_KXP">
                <xsl:call-template name="modsPhysicalDescriptionKXP"/>
            </xsl:when>
            <xsl:when test="$picaMode = $pica_RDA">
                <xsl:call-template name="modsPhysicalDescriptionRDA"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="modsPhysicalDescriptionEpub">
        <xsl:for-each select="./p:datafield[@tag='034D']/p:subfield[@code='a' and contains(., 'Seite')]">
            <mods:physicalDescription>
                <mods:extent unit="pages">
                    <xsl:value-of select="normalize-space(substring-before(substring-after(.,'('),'Seite'))"/>
                </mods:extent>
            </mods:physicalDescription>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="modsPhysicalDescriptionKXP">
        <mods:physicalDescription>
            <xsl:for-each
                    select="./p:datafield[@tag='034D']/p:subfield[@code='a']">   <!--  4060 Umfang, Seiten -->
                <mods:extent>
                    <xsl:value-of select="."/>
                </mods:extent>
            </xsl:for-each>
            <xsl:for-each
                    select="./p:datafield[@tag='034M']/p:subfield[@code='a']">   <!--  4061 Illustrationen -->
                <mods:extent>
                    <xsl:value-of select="."/>
                </mods:extent>
            </xsl:for-each>
            <xsl:for-each
                    select="./p:datafield[@tag='034I']/p:subfield[@code='a']">   <!-- 4062 Format, Größe  -->
                <mods:extent>
                    <xsl:value-of select="."/>
                </mods:extent>
            </xsl:for-each>
            <xsl:for-each
                    select="./p:datafield[@tag='034K']/p:subfield[@code='a']">   <!-- 4063 Begleitmaterial  -->
                <mods:extent>
                    <xsl:value-of select="."/>
                </mods:extent>
            </xsl:for-each>

            <xsl:choose> <!-- 4238 Technische Angaben zum elektr. Dokument  -->
                <xsl:when
                        test="contains(./p:datafield[@tag='037H']/p:subfield[@code='a'], 'Digitalisierungsvorlage: Original')"> <!-- alt -->
                    <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
                </xsl:when>
                <xsl:when
                        test="contains(./p:datafield[@tag='037H']/p:subfield[@code='a'], 'Digitalisierungsvorlage: Primärausgabe')">
                    <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
                </xsl:when>
                <xsl:when
                        test="contains(./p:datafield[@tag='037H']/p:subfield[@code='a'], 'Digitalisierungsvorlage: Mikrofilm')">
                    <mods:digitalOrigin>digitized microfilm</mods:digitalOrigin>
                </xsl:when>
                <xsl:otherwise>
                    <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
                </xsl:otherwise>
            </xsl:choose>
        </mods:physicalDescription>
    </xsl:template>

    <xsl:template name="modsPhysicalDescriptionRDA">
        <xsl:variable name="pica0500_2" select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)"/>

        <xsl:choose>
            <!-- ToDo: 2. If für Ob-Stufen: Wenn keine ppnA und 0500 2. Pos ='b',
        dann originInfo[@eventtype='creation'] aus O-Aufnahmen-Feldern:
  bei RDA-Aufnahmen keine A-PPN im Pica vorhanden -> Daten aus Expansion nehmen
  ggf. per ZDB-ID die SRU-Schnittstelle anfragen
        - publisher aus 039I $e
        - placeTerm aus 039I $d
        - datesissued aus 039I $f
        - issuance -> Konstante "serial"
        - physicalDescription -> wie unten (variable nicht vergessen!) 	-->
            <xsl:when test="not($pica0500_2='v')">
                <xsl:variable name="digitalOrigin">
                    <xsl:choose>  <!-- 4238 Technische Angaben zum elektr. Dokument, RDA ok -->
                        <xsl:when
                                test="contains(./p:datafield[@tag='037H']/p:subfield[@code='a'], 'Digitalisierungsvorlage: Original')"> <!-- alt -->
                            <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
                        </xsl:when>
                        <xsl:when
                                test="contains(./p:datafield[@tag='037H']/p:subfield[@code='a'], 'Digitalisierungsvorlage: Primärausgabe')">
                            <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
                        </xsl:when>
                        <xsl:when
                                test="contains(./p:datafield[@tag='037H']/p:subfield[@code='a'], 'Digitalisierungsvorlage: Mikrofilm')">
                            <mods:digitalOrigin>digitized microfilm</mods:digitalOrigin>
                        </xsl:when>
                        <xsl:otherwise>
                            <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <!-- RDA -->
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
                <xsl:choose>
                    <xsl:when
                            test="$picaA/p:record/p:datafield[@tag='034D' or @tag='034M' or @tag='034I' or @tag='034K']">
                        <mods:physicalDescription>
                            <xsl:for-each
                                    select="$picaA/p:record/p:datafield[@tag='034D']/p:subfield[@code='a']">   <!-- 4060 Umfang, Seiten -->
                                <mods:extent>
                                    <xsl:value-of select="."/>
                                </mods:extent>
                            </xsl:for-each>
                            <xsl:for-each
                                    select="$picaA/p:record/p:datafield[@tag='034M']/p:subfield[@code='a']">   <!-- 4061 Illustrationen -->
                                <mods:extent>
                                    <xsl:value-of select="."/>
                                </mods:extent>
                            </xsl:for-each>
                            <xsl:for-each
                                    select="$picaA/p:record/p:datafield[@tag='034I']/p:subfield[@code='a']">   <!-- 4062 Format, Größe -->
                                <mods:extent>
                                    <xsl:value-of select="."/>
                                </mods:extent>
                            </xsl:for-each>
                            <xsl:for-each
                                    select="$picaA/p:record/p:datafield[@tag='034K']/p:subfield[@code='a']">   <!-- 4063 Begleitmaterial -->
                                <mods:extent>
                                    <xsl:value-of select="."/>
                                </mods:extent>
                            </xsl:for-each>
                            <xsl:copy-of select="$digitalOrigin"/>
                        </mods:physicalDescription>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="./p:datafield[@tag='034D' or @tag='034M' or @tag='034I' or @tag='034K']">
                            <mods:physicalDescription>
                                <xsl:for-each
                                        select="./p:datafield[@tag='034D']/p:subfield[@code='a']">   <!-- 4060 Umfang, Seiten -->
                                    <mods:extent>
                                        <xsl:value-of select="."/>
                                    </mods:extent>
                                </xsl:for-each>
                                <xsl:for-each
                                        select="./p:datafield[@tag='034M']/p:subfield[@code='a']">   <!-- 4061 Illustrationen -->
                                    <mods:extent>
                                        <xsl:value-of select="."/>
                                    </mods:extent>
                                </xsl:for-each>
                                <xsl:for-each
                                        select="./p:datafield[@tag='034I']/p:subfield[@code='a']">   <!-- 4062 Format, Größe -->
                                    <mods:extent>
                                        <xsl:value-of select="."/>
                                    </mods:extent>
                                </xsl:for-each>
                                <xsl:for-each
                                        select="./p:datafield[@tag='034K']/p:subfield[@code='a']">   <!-- 4063 Begleitmaterial -->
                                    <mods:extent>
                                        <xsl:value-of select="."/>
                                    </mods:extent>
                                </xsl:for-each>
                                <xsl:copy-of select="$digitalOrigin"/>
                            </mods:physicalDescription>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- Wenn 0500 2. Pos ='v',
   dann originInfo[@eventtype='creation'] aus O-Aufnahmen-Feldern:
    - publisher und placeTerm nicht vorhanden (keine Av-Stufe vorhanden)
    - datesissued aus 011@ $r
    - issuance -> Konstante "serial"
    - physicalDescription -->
            <xsl:otherwise>
                <mods:physicalDescription>
                    <xsl:for-each
                            select="./p:datafield[@tag='034D']/p:subfield[@code='a']">   <!-- 4060 Umfang, Seiten aus O-Aufnahme, Problem: "1 Online-Ressource (...)"-->
                        <mods:extent>
                            <xsl:value-of select="."/>
                        </mods:extent>
                    </xsl:for-each>
                    <xsl:for-each
                            select="./p:datafield[@tag='037H']/p:subfield[@code='a']">   <!-- 4238 Technische Angaben zum elektr. Dokument, RDA ok -->
                        <xsl:if test="contains(., 'Digitalisierungsvorlage: Original')"> <!-- alt -->
                            <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
                        </xsl:if>
                        <xsl:if test="contains(., 'Digitalisierungsvorlage: Primärausgabe')">
                            <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
                        </xsl:if>
                        <xsl:if test="contains(., 'Digitalisierungsvorlage: Mikrofilm')">
                            <mods:digitalOrigin>digitized microfilm</mods:digitalOrigin>
                        </xsl:if>
                    </xsl:for-each>
                </mods:physicalDescription>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>
