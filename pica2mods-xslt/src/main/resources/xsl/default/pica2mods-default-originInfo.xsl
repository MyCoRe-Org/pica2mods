<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
                xmlns:xsL="http://www.w3.org/1999/XSL/Transform" version="3.0"
                exclude-result-prefixes="mods pica2mods">


    <xsl:import use-when="system-property('XSL_TESTING')='true'" href="_common/pica2mods-functions.xsl"/>

    <!-- This template is for testing purposes-->
    <xsl:template match="p:record">
        <mods:mods>
            <xsl:call-template name="modsOriginInfo" />
        </mods:mods>
    </xsl:template>

    <xsl:template name="modsOriginInfo">
        <xsl:variable name="pica0500_2"
                      select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)"/>
        <xsl:variable name="picaMode" select="pica2mods:detectPicaMode(.)" />
        <xsl:choose>
            <xsl:when test="$picaMode = 'EPUB'">
                <mods:originInfo eventType="publication"> <!-- 4030 033A -->
                    <xsl:call-template name="common_publisher_place">
                      <xsl:with-param name="record" select="." />
                    </xsl:call-template>
                    <xsl:call-template name="common_norm_place">
                      <xsL:with-param name="record" select="." />
                    </xsl:call-template>
                    <xsl:call-template name="common_edition">
                       <xsL:with-param name="record" select="." />
                    </xsl:call-template>
                    <xsl:call-template name="epubDate"/>
                    <xsl:call-template name="common_issuance">
                        <xsl:with-param name="pica0500_2" select="$pica0500_2"/>
                    </xsl:call-template>
                </mods:originInfo>
                <xsl:call-template name="epubOnlinePublication"/>
            </xsl:when>
            <xsl:when test="$picaMode = 'KXP'">
                <!-- check use of eventtype attribute -->
                <mods:originInfo eventType="creation">
                    <xsl:call-template name="common_publisher_place">
                      <xsL:with-param name="record" select="." />
                    </xsl:call-template>
                    <xsl:call-template name="common_norm_place">
                      <xsL:with-param name="record" select="." />
                    </xsl:call-template>
                    <xsl:call-template name="kxpDate"/>
                    <xsl:call-template name="common_edition">
                       <xsL:with-param name="record" select="." />
                    </xsl:call-template>
                    <xsl:call-template name="common_issuance">
                        <xsl:with-param name="pica0500_2" select="$pica0500_2"/>
                    </xsl:call-template>
                </mods:originInfo>
                <xsl:call-template name="kxpOnlinePublication"/>
            </xsl:when>
            <xsl:when test="$picaMode = 'RDA'">
                <xsl:choose>
                    <xsl:when test="($pica0500_2='v')">
                        <mods:originInfo eventType="creation">
                            <xsl:if test="./p:datafield[@tag='011@']/p:subfield[@code='r']">
                                <mods:dateIssued encoding="w3cdtf" keyDate="yes">
                                    <xsl:value-of select="./p:datafield[@tag='011@']/p:subfield[@code='r']"/>
                                </mods:dateIssued>
                            </xsl:if>
                            <xsL:call-template name="common_edition">
                              <xsL:with-param name="record" select="." />
                            </xsL:call-template>
                            <mods:issuance>serial</mods:issuance>
                        </mods:originInfo>
                    </xsl:when>
                    <xsl:otherwise>
                    <!-- check use of eventtype attribute -->
                    <!-- RDA: from A-Aufnahme -->
                        <xsl:variable name="picaA" select="pica2mods:queryPicaDruck(.)" />
                        <xsl:if test="$picaA/*">
                            <mods:originInfo eventType="creation">
                                <xsL:call-template name="common_publisher_place">
                                   <xsL:with-param name="record" select="$picaA" />
                                </xsL:call-template>
                                <xsL:call-template name="common_norm_place">
                                   <xsL:with-param name="record" select="$picaA" />
                                </xsL:call-template>
                                
                                <xsl:for-each select="$picaA/p:datafield[@tag='011@']">
                                    <xsl:choose>
                                        <xsl:when test="./p:subfield[@code='b']">
                                            <mods:dateIssued keyDate="yes" encoding="w3cdtf" point="start">
                                                <xsl:value-of select="./p:subfield[@code='a']"/>
                                            </mods:dateIssued>
                                            <mods:dateIssued encoding="w3cdtf" point="end">
                                                <xsl:value-of select="./p:subfield[@code='b']"/>
                                            </mods:dateIssued>
                                            <xsl:if test="./p:subfield[@code='n']">
                                                <mods:dateIssued qualifier="approximate">
                                                    <xsl:value-of select="./p:subfield[@code='n']"/>
                                                </mods:dateIssued>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:choose>
                                                <xsl:when test="contains(./p:subfield[@code='a'], 'X')">
                                                    <mods:dateIssued keyDate="yes" encoding="w3cdtf" point="start">
                                                        <xsl:value-of
                                                                select="translate(./p:subfield[@code='a'], 'X','0')"/>
                                                    </mods:dateIssued>
                                                    <mods:dateIssued encoding="w3cdtf" point="end">
                                                        <xsl:value-of
                                                                select="translate(./p:subfield[@code='a'], 'X', '9')"/>
                                                    </mods:dateIssued>
                                                    <xsl:if test="./p:subfield[@code='n']">
                                                        <mods:dateIssued qualifier="approximate">
                                                            <xsl:value-of select="./p:subfield[@code='n']"/>
                                                        </mods:dateIssued>
                                                    </xsl:if>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <mods:dateIssued keyDate="yes" encoding="w3cdtf">
                                                        <xsl:value-of select="./p:subfield[@code='a']"/>
                                                    </mods:dateIssued>
                                                    <xsl:if test="./p:subfield[@code='n']">
                                                        <mods:dateIssued qualifier="approximate">
                                                            <xsl:value-of select="./p:subfield[@code='n']"/>
                                                        </mods:dateIssued>
                                                    </xsl:if>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>

                                <xsL:call-template name="common_edition">
                                  <xsL:with-param name="record" select="$picaA" />
                                </xsL:call-template>
                                
                                <xsl:call-template name="common_issuance">
                                    <xsl:with-param name="pica0500_2" select="$picaA/p:datafield[@tag='002@']/p:subfield[@code='0']"/>
                                </xsl:call-template>
                            </mods:originInfo>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>

                <!-- mehrere digitalisierende Einrichtungen -->
                <!-- RS: mods:originInfo wiederholen oder wie jetzt mehrere Publisher/Orte aufsammeln?
                    - Wir verlieren so die Beziehung publisher-ort -->
                <mods:originInfo eventType="online_publication"> <!-- 4030 -->
                    <xsL:call-template name="common_publisher_place">
                       <xsL:with-param name="record" select="." />
                    </xsL:call-template>
                    
                    <mods:edition>[Electronic edition]</mods:edition>
                    <xsl:for-each select="./p:datafield[@tag='011@']">   <!-- 1109, RDA 1100 011@ -->
                        <xsl:choose>
                            <xsl:when test="./p:subfield[@code='b']">
                                <mods:dateCaptured encoding="w3cdtf" keyDate="yes" point="start">
                                    <xsl:value-of select="./p:subfield[@code='a']"/>
                                </mods:dateCaptured>
                                <mods:dateCaptured encoding="w3cdtf" point="end">
                                    <xsl:value-of select="./p:subfield[@code='b']"/>
                                </mods:dateCaptured>
                            </xsl:when>
                            <xsl:otherwise>
                                <mods:dateCaptured encoding="w3cdtf" keyDate="yes">
                                    <xsl:value-of select="./p:subfield[@code='a']"/>
                                </mods:dateCaptured>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </mods:originInfo>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="kxpOnlinePublication">
        <mods:originInfo eventType="online_publication">
            <!--wenn keine 4031, dann aus 4048/033N -->
            <!--hier mehrere digitalisierende Einrichtungen for each-->
            <xsl:for-each select="./p:datafield[@tag='033B' or @tag='033N']"> <!-- 4031 Ort, Verlag -->
                <xsl:if test="./p:subfield[@code='n']">
                    <mods:publisher>
                        <xsl:value-of select="./p:subfield[@code='n']"/>
                    </mods:publisher>
                </xsl:if>
                <xsl:if test="./p:subfield[@code='p']">
                    <mods:place>
                        <mods:placeTerm type="text">
                            <xsl:value-of select="./p:subfield[@code='p']"/>
                        </mods:placeTerm>
                    </mods:place>
                </xsl:if>
            </xsl:for-each>
            <mods:edition>[Electronic edition]</mods:edition>

            <xsl:for-each select="./p:datafield[@tag='011B']">   <!-- 1109 -->
                <xsl:choose>
                    <xsl:when test="./p:subfield[@code='b']">
                        <mods:dateCaptured encoding="iso8601" point="start" keyDate="yes">
                            <xsl:value-of select="./p:subfield[@code='a']"/>
                        </mods:dateCaptured>
                        <mods:dateCaptured encoding="iso8601" point="end">
                            <xsl:value-of select="./p:subfield[@code='b']"/>
                        </mods:dateCaptured>
                    </xsl:when>
                    <xsl:otherwise>
                        <mods:dateCaptured encoding="iso8601" keyDate="yes">
                            <xsl:value-of select="./p:subfield[@code='a']"/>
                        </mods:dateCaptured>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </mods:originInfo>
    </xsl:template>
    <xsl:template name="epubOnlinePublication">
        <xsl:if test="./p:datafield[@tag='033E']">
            <mods:originInfo eventType="online_publication"> <!-- 4034 -->
                <xsl:if test="./p:datafield[@tag='033E']/p:subfield[@code='n']">  <!-- 4034 $n Verlag -->
                    <mods:publisher>
                        <xsl:value-of select="./p:datafield[@tag='033E']/p:subfield[@code='n']"/>
                    </mods:publisher>
                </xsl:if>
                <xsl:if test="./p:datafield[@tag='033E']/p:subfield[@code='p']">  <!-- 4034 $p Ort -->
                    <mods:place>
                        <mods:placeTerm type="text">
                            <xsl:value-of select="./p:datafield[@tag='033E']/p:subfield[@code='p']"/>
                        </mods:placeTerm>
                    </mods:place>
                </xsl:if>
                <xsl:if test="./p:datafield[@tag='033E']/p:subfield[@code='h']">  <!-- 4034 $h Jahr -->
                    <mods:dateCaptured encoding="iso8601">
                        <xsl:value-of select="./p:datafield[@tag='033E']/p:subfield[@code='h']"/>
                    </mods:dateCaptured>
                </xsl:if>
            </mods:originInfo>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="common_issuance">
        <xsl:param name="pica0500_2"/>
        <xsl:choose>
            <xsl:when test="$pica0500_2='a'">
            <mods:issuance>monographic</mods:issuance>
            </xsl:when>
            <xsl:when test="$pica0500_2='b'">
                <mods:issuance>serial</mods:issuance>
            </xsl:when>
            <xsl:when test="$pica0500_2='c'">
                <mods:issuance>multipart monograph</mods:issuance>
            </xsl:when>
            <xsl:when test="$pica0500_2='d'">
                <mods:issuance>serial</mods:issuance>
            </xsl:when>
            <xsl:when test="$pica0500_2='f'">
                <mods:issuance>monographic</mods:issuance>
            </xsl:when>
            <xsl:when test="$pica0500_2='F'">
                <mods:issuance>monographic</mods:issuance>
            </xsl:when>
            <xsl:when test="$pica0500_2='j'">
                <mods:issuance>single unit</mods:issuance>
            </xsl:when>
            <xsl:when test="$pica0500_2='s'">
                <mods:issuance>single unit</mods:issuance>
            </xsl:when>
            <xsl:when test="$pica0500_2='v'">
                <mods:issuance>serial</mods:issuance>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

  <xsl:template name="common_edition">
    <xsl:param name="record" />
    <xsl:for-each select="$record/p:datafield[@tag='032@']"> <!-- 4020 Ausgabe -->
      <mods:edition>
        <xsl:choose>
          <xsl:when test="./p:subfield[@code='h']">
            <xsl:value-of select="./p:subfield[@code='a']" />
            /
            <xsl:value-of select="./p:subfield[@code='h']" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="./p:subfield[@code='a']" />
          </xsl:otherwise>
        </xsl:choose>
      </mods:edition>
    </xsl:for-each>
  </xsl:template>

    <xsl:template name="kxpDate">
        <xsl:for-each select="./p:datafield[@tag='011@']">
            <xsl:choose>
                <xsl:when test="./p:subfield[@code='b']">
                    <mods:dateIssued keyDate="yes" encoding="w3cdtf" point="start">
                        <xsl:value-of select="./p:subfield[@code='a']"/>
                    </mods:dateIssued>
                    <mods:dateIssued encoding="w3cdtf" point="end">
                        <xsl:value-of select="./p:subfield[@code='b']"/>
                    </mods:dateIssued>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <!-- TODO: check how different this is to epubDate-->
                        <xsl:when test="contains(./p:subfield[@code='a'], 'X')">
                            <mods:dateIssued keyDate="yes" encoding="w3cdtf" point="start">
                                <xsl:value-of select="translate(./p:subfield[@code='a'], 'X','0')"/>
                            </mods:dateIssued>
                            <mods:dateIssued encoding="w3cdtf" point="end">
                                <xsl:value-of select="translate(./p:subfield[@code='a'], 'X', '9')"/>
                            </mods:dateIssued>
                        </xsl:when>
                        <xsl:otherwise>
                            <mods:dateIssued keyDate="yes" encoding="w3cdtf">
                                <xsl:value-of select="./p:subfield[@code='a']"/>
                            </mods:dateIssued>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="./p:subfield[@code='n']">
                <mods:dateIssued qualifier="approximate">
                    <xsl:value-of select="./p:subfield[@code='n']"/>
                </mods:dateIssued>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- normierte Orte 4040, außer Hochschulort $4=uvp -->
    <!-- PPN: 896299511 Petropoli -> Sankt Petersburg -->
    <xsl:template name="common_norm_place">
        <xsl:param name="record" />

        <xsl:for-each select="$record/p:datafield[@tag='033D' and not(./p:subfield[@code='4']='uvp')]">
            <mods:place supplied="yes">
                <mods:placeTerm lang="ger" type="text">
                    <xsl:if test="./p:subfield[@code='9']">
                        <xsL:variable name="pOrt" select="pica2mods:queryPicaFromUnAPIWithPPN('k10plus', ./p:subfield[@code='9'])" />
                        <xsl:attribute name="authorityURI">http://d-nb.info/gnd/</xsl:attribute> 
                        <xsl:attribute name="valueURI"><xsl:value-of select="$pOrt/p:datafield[@tag='003U']/p:subfield[@code='a']" /></xsl:attribute> 
                    </xsl:if>
                    <xsl:value-of select="./p:subfield[@code='p']"/>
                </mods:placeTerm>
            </mods:place>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="common_publisher_place">
        <xsl:param name="record" />
        <xsl:for-each select="$record/p:datafield[@tag='033A']">
            <xsl:if test="./p:subfield[@code='n']">  <!-- 4030 Ort, Verlag -->
                <mods:publisher>
                    <xsl:value-of select="./p:subfield[@code='n']"/>
                </mods:publisher>
            </xsl:if>
            <xsl:for-each select="./p:subfield[@code='p']">
                <mods:place>
                    <mods:placeTerm type="text">
                        <xsl:value-of select="."/>
                    </mods:placeTerm>
                </mods:place>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="epubDate">
        <xsl:for-each select="./p:datafield[@tag='011@']">   <!-- 1100 -->
            <xsl:choose>
                <xsl:when test="./p:subfield[@code='b']">
                    <mods:dateIssued keyDate="yes" encoding="w3cdtf" point="start">
                        <xsl:value-of select="./p:subfield[@code='a']"/>
                    </mods:dateIssued>
                    <mods:dateIssued encoding="w3cdtf" point="end">
                        <xsl:value-of select="./p:subfield[@code='b']"/>
                    </mods:dateIssued>
                </xsl:when>
                <xsl:otherwise>
                    <mods:dateIssued keyDate="yes" encoding="w3cdtf">
                        <xsl:if test="substring(../p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)='b' or substring(../p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)='d'">
                            <xsl:attribute name="point">start</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="./p:subfield[@code='a']"/>
                    </mods:dateIssued>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="./p:subfield[@code='n']">
                <mods:dateIssued qualifier="approximate">
                    <xsl:value-of select="./p:subfield[@code='n']"/>
                </mods:dateIssued>
            </xsl:if>
        </xsl:for-each>

        <!-- PPN 1726228770 an 2 Hochschulen eingereicht -->
        <xsl:if test="./p:datafield[@tag='037C']/p:subfield[@code='f']">  <!-- 4204 Hochschulschriftenvermerk, Jahr der Verteidigung -->
            <mods:dateOther type="defence" encoding="w3cdtf">
                <xsl:value-of select="./p:datafield[@tag='037C']/p:subfield[@code='f'][1]"/>
            </mods:dateOther>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
