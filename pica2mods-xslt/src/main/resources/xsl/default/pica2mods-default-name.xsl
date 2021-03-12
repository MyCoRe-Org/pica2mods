<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
                exclude-result-prefixes="mods pica2mods">

    <xsl:import use-when="system-property('XSL_TESTING')='true'" href="_common/pica2mods-functions.xsl"/>
    
    <!-- This template is for testing purposes-->
    <xsl:template match="p:record">
        <mods:mods>
            <xsl:call-template name="modsName"/>
        </mods:mods>
    </xsl:template>

    <xsl:template name="modsName">
        <xsl:call-template name="COMMON_PersonalName"/>
        <xsl:call-template name="COMMON_CorporateName"/>
    </xsl:template>

    <xsl:template name="COMMON_PersonalName">
        <!-- Lb: RDA, jetzt marcrelatorcode gemäß $4 bzw. ausgeschrieben $B -->
        <!-- 033J RAK: Drucker, Verleger bei Alten Drucken, in RDA nicht zugelassen -->
        <xsl:for-each select="./p:datafield[starts-with(@tag, '028') or @tag='033J']">
            <xsl:choose>
                <xsl:when test="./p:subfield[@code='9']">
                    <xsl:variable name="ppn" select="./p:subfield[@code='9']" />
                    <xsl:variable name="tp" select="pica2mods:queryPicaFromUnAPIWithPPN('k10plus', $ppn)" />
                    <xsl:if test="starts-with($tp/p:datafield[@tag='002@']/p:subfield[@code='0'], 'Tp')">
                        <mods:name type="personal">
                            <xsl:if test="$tp/p:datafield[@tag='028A']/p:subfield[@code='d']">
                                <mods:namePart type="given"><xsl:value-of select="$tp/p:datafield[@tag='028A']/p:subfield[@code='d']" /></mods:namePart>
                            </xsl:if>
                            <xsl:if test="$tp/p:datafield[@tag='028A']/p:subfield[@code='a']">
                                <mods:namePart type="family"><xsl:value-of select="$tp/p:datafield[@tag='028A']/p:subfield[@code='a']" /></mods:namePart>
                            </xsl:if>
                            <xsl:if test="$tp/p:datafield[@tag='028A']/p:subfield[@code='P']">
                                <mods:namePart type="family"><xsl:value-of select="$tp/p:datafield[@tag='028A']/p:subfield[@code='P']" /></mods:namePart>
                            </xsl:if>
                            <xsl:if test="$tp/p:datafield[@tag='028A']/p:subfield[@code='c']">
                                <mods:namePart type="termsOfAddress"><xsl:value-of select="$tp/p:datafield[@tag='028A']/p:subfield[@code='c']" /></mods:namePart>
                            </xsl:if>
                            <xsl:if test="$tp/p:datafield[@tag='028A']/p:subfield[@code='n']">
                                <mods:namePart type="termsOfAddress"><xsl:value-of select="$tp/p:datafield[@tag='028A']/p:subfield[@code='n']" /></mods:namePart>
                            </xsl:if>
                            <xsl:if test="$tp/p:datafield[@tag='028A']/p:subfield[@code='l']">
                                <mods:namePart type="termsOfAddress"><xsl:value-of select="$tp/p:datafield[@tag='028A']/p:subfield[@code='l']" /></mods:namePart>
                            </xsl:if>
                            <xsl:for-each select="$tp/p:datafield[@tag='060R' and ./p:subfield[@code='4']='datl']">
                                <xsl:if test="./p:subfield[@code='a']">
                                    <xsl:variable name="out_date">
                                        <xsl:value-of select="./p:subfield[@code='a']"/>
                                        -
                                        <xsl:value-of select="./p:subfield[@code='b']"/>
                                    </xsl:variable>
                                    <mods:namePart type="date">
                                        <xsl:value-of select="normalize-space($out_date)"></xsl:value-of>
                                    </mods:namePart>
                                </xsl:if>
                                <xsl:if test="./p:subfield[@code='d']">
                                    <mods:namePart type="date">
                                        <xsl:value-of select="./p:subfield[@code='d']"></xsl:value-of>
                                    </mods:namePart>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:call-template name="COMMON_PersonalName_ROLES">
                                <xsl:with-param name="datafield" select="."/>
                            </xsl:call-template>
                            <mods:nameIdentifier type="gnd">
                                <xsl:value-of
                                        select="$tp/p:datafield[@tag='007K' and ./p:subfield[@code='a']='gnd']/p:subfield[@code='0']"/>
                            </mods:nameIdentifier>
                            <xsl:if test="$tp/p:datafield[@tag='006X' and ./p:subfield[@code='S']='orcid']">
                                <mods:nameIdentifier type="orcid">
                                    <xsl:value-of
                                            select="$tp/p:datafield[@tag='006X' and ./p:subfield[@code='S']='orcid']/p:subfield[@code='0']"/>
                                </mods:nameIdentifier>
                            </xsl:if>
                        </mods:name>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <mods:name type="personal">
                        <xsl:if test="./p:subfield[@code='d']">
                            <mods:namePart type="given">
                                <xsl:value-of select="./p:subfield[@code='d']" />
                            </mods:namePart>
                        </xsl:if>
                        <xsl:if test="./p:subfield[@code='a']">
                            <mods:namePart type="family">
                                <xsl:value-of select="./p:subfield[@code='a']" />
                            </mods:namePart>
                        </xsl:if>
                        <xsl:if test="./p:subfield[@code='c']">
                            <mods:namePart type="termsOfAddress">
                                <xsl:value-of select="./p:subfield[@code='c']" />
                            </mods:namePart>
                        </xsl:if>

                        <xsl:if test="./p:subfield[@code='P']">
                            <mods:namePart>
                                <xsl:value-of select="./p:subfield[@code='P']" />
                            </mods:namePart>
                        </xsl:if>
                        <xsl:if test="./p:subfield[@code='n']">
                            <mods:namePart type="termsOfAddress">
                                <xsl:value-of select="./p:subfield[@code='n']" />
                            </mods:namePart>
                        </xsl:if>
                        <xsl:if test="./p:subfield[@code='l']">
                            <mods:namePart type="termsOfAddress">
                                <xsl:value-of select="./p:subfield[@code='l']" />
                            </mods:namePart>
                        </xsl:if>
                        <xsl:call-template name="COMMON_PersonalName_ROLES">
                            <xsl:with-param name="datafield" select="." />
                        </xsl:call-template>
                    </mods:name>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="COMMON_PersonalName_ROLES">
        <xsl:param name="datafield" />
        <xsl:choose>
            <xsl:when test="$datafield/p:subfield[@code='4']">
                <xsl:for-each select="$datafield/p:subfield[@code='4']">
                    <mods:role>
                        <xsl:if test="preceding-sibling::p:subfield[@code='B']">
                            <mods:roleTerm type="text" authority="GBV">
                                <xsl:value-of select="preceding-sibling::p:subfield[@code='B'][last()]" />
                            </mods:roleTerm>
                        </xsl:if>
                        <mods:roleTerm type="code" authority="marcrelator">
                            <xsl:value-of select="." />
                        </mods:roleTerm>
                    </mods:role>
                </xsl:for-each>
            </xsl:when>

            <!-- Alt: Heuristiken für RAK-Aufnahmen -->
            <xsl:when test="$datafield/p:subfield[@code='B']">
                <mods:role>
                    <mods:roleTerm type="code" authority="marcrelator">
                        <xsl:choose>
                            <!-- RAK WB §185, 2 -->
                            <xsl:when test="$datafield/p:subfield[@code='B']='Bearb.'">ctb</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='Begr.'">org</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='Hrsg.'">edt</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='Ill.'">ill</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='Komp.'">cmp</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='Mitarb.'">ctb</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='Red.'">red</xsl:when>
                            <!-- GBV Katalogisierungsrichtlinie -->
                            <xsl:when test="$datafield/p:subfield[@code='B']='Adressat'">rcp</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='angebl. Hrsg.'">edt</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='mutmaßl. Hrsg.'">edt</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='Komm.'">ann</xsl:when><!-- Kommentator = annotator -->
                            <xsl:when test="$datafield/p:subfield[@code='B']='Stecher'">egr</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='angebl. Übers.'">trl</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='mutmaßl. Übers.'">trl</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='angebl. Verf.'">dub</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='mutmaßl. Verf.'">dub</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='Verstorb.'">oth</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='Zeichner'">drm</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='Präses'">pra</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='Resp.'">rsp</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='Widmungsempfänger'">dto</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='Zensor'">cns</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='Beiträger'">ctb</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='Beiträger k.'">ctb</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='Beiträger m.'">ctb</xsl:when>
                            <xsl:when test="$datafield/p:subfield[@code='B']='Interpr.'">prf</xsl:when> <!-- Interpret = Performer-->
                            <xsl:otherwise>oth</xsl:otherwise>
                        </xsl:choose>
                    </mods:roleTerm>
                    <mods:roleTerm type="text" authority="GBV"><xsl:value-of select="$datafield/p:subfield[@code='B']" /></mods:roleTerm>
                </mods:role>
            </xsl:when>
            <xsl:when test="@tag='028A' or @tag='028B'">
                <mods:role>
                    <mods:roleTerm type="code" authority="marcrelator">aut</mods:roleTerm>
                    <mods:roleTerm type="text" authority="GBV">Verfasser</mods:roleTerm>
                </mods:role>
            </xsl:when>
            <xsl:when test="@tag='033J'">
                <mods:role>
                    <mods:roleTerm type="text" authority="GBV">DruckerIn</mods:roleTerm>
                    <mods:roleTerm type="code" authority="marcrelator">prt</mods:roleTerm>
                </mods:role>
            </xsl:when>
            <xsl:otherwise>
                <mods:role><mods:roleTerm type="code" authority="marcrelator">oth</mods:roleTerm></mods:role>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="COMMON_CorporateName">
        <!--RAK 033J = 4033 Druckernormdaten, aber kein Ort angegeben (müsste aus GND gelesen werden) 
                       MODS unterstützt keine authorityURIs für Verlage deshalb 033A verwenden , 
                       RDA: Drucker-/Verlegernormdaten als beteiligte Körperschaft in 3010/3110 mit entspr. Rollenbezeichnung -->
        <!-- Lb: RDA, jetzt marcrelatorcode gemäß $4 bzw. ausgeschrieben $B -->
        <!-- zusätzlich geprüft 033J =  4043 Druckernormadaten (alt) -->
        <xsl:for-each select="./p:datafield[starts-with(@tag, '029') or @tag='033J']">
            <xsl:choose>
                <xsl:when test="./p:subfield[@code='9']">
                    <xsl:variable name="ppn" select="./p:subfield[@code='9']" />
                    <xsl:variable name="tb" select="pica2mods:queryPicaFromUnAPIWithPPN('k10plus', $ppn)" />
                    <xsl:if test="starts-with($tb/p:datafield[@tag='002@']/p:subfield[@code='0'], 'Tb')">
                        <mods:name type="corporate">
                            <mods:nameIdentifier type="gnd"><xsl:value-of select="$tb/p:datafield[@tag='007K' and ./p:subfield[@code='a']='gnd']/p:subfield[@code='0']" /></mods:nameIdentifier>
                            <xsl:if test="$tb/p:datafield[@tag='029A']/p:subfield[@code='a']">
                                <mods:namePart><xsl:value-of select="$tb/p:datafield[@tag='029A']/p:subfield[@code='a']" /></mods:namePart>
                            </xsl:if>
                            <xsl:if test="$tb/p:datafield[@tag='029A']/p:subfield[@code='b']">
                                <mods:namePart><xsl:value-of select="$tb/p:datafield[@tag='029A']/p:subfield[@code='b']" /></mods:namePart>
                            </xsl:if>
                            <xsl:if test="$tb/p:datafield[@tag='029A']/p:subfield[@code='g']">
                                <mods:namePart><xsl:value-of select="$tb/p:datafield[@tag='029A']/p:subfield[@code='g']" /></mods:namePart>
                            </xsl:if>
                            <xsl:if test="$tb/p:datafield[@tag='065A']/p:subfield[@code='a']">
                                <mods:namePart><xsl:value-of select="$tb/p:datafield[@tag='065A']/p:subfield[@code='a']" /></mods:namePart>
                            </xsl:if>
                            <xsl:if test="$tb/p:datafield[@tag='065A']/p:subfield[@code='g']">
                                <mods:namePart><xsl:value-of select="$tb/p:datafield[@tag='065A']/p:subfield[@code='g']" /></mods:namePart>
                            </xsl:if>

                            <xsl:for-each select="$tb/p:datafield[@tag='060R' and (./p:subfield[@code='4']='datb' or ./p:subfield[@code='4']='datv')]">
                                <xsl:if test="./p:subfield[@code='a']">
                                    <xsl:variable name="out_date">
                                        <xsl:value-of select="./p:subfield[@code='a']" />
                                        -
                                        <xsl:value-of select="./p:subfield[@code='b']" />
                                    </xsl:variable>
                                    <mods:namePart type="date"><xsl:value-of select="normalize-space($out_date)"/></mods:namePart>
                                </xsl:if>
                                <xsl:if test="./p:subfield[@code='d']">
                                    <mods:namePart type="date"><xsl:value-of select="./p:subfield[@code='d']" /></mods:namePart>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:call-template name="COMMON_CorporateName_ROLES">
                                <xsl:with-param name="datafield" select="." />
                            </xsl:call-template>
                        </mods:name>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <mods:name type="corporate">
                        <xsl:if test="./p:subfield[@code='a']">
                            <mods:namePart>
                                <xsl:value-of select="./p:subfield[@code='a']" />
                            </mods:namePart>
                        </xsl:if>
                        <xsl:if test="./p:subfield[@code='b']">
                            <mods:namePart>
                                <xsl:value-of select="./p:subfield[@code='b']" />
                            </mods:namePart>
                        </xsl:if>
                        <xsl:if test="./p:subfield[@code='d']">
                            <mods:namePart type="date">
                                <xsl:value-of select="./p:subfield[@code='d']" />
                            </mods:namePart>
                        </xsl:if>
                        <xsl:if test="./p:subfield[@code='g']"> <!-- Zusatz-->
                            <mods:namePart>
                                <xsl:value-of select="./p:subfield[@code='g']" />
                            </mods:namePart>
                        </xsl:if>
                        <xsl:if test="./p:subfield[@code='c']"> <!-- non-normative type "place" -->
                            <mods:namePart>
                                <xsl:value-of select="./p:subfield[@code='c']" />
                            </mods:namePart>
                        </xsl:if>
                        <xsl:call-template name="COMMON_CorporateName_ROLES">
                            <xsl:with-param name="datafield" select="." />
                        </xsl:call-template>
                    </mods:name>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="COMMON_CorporateName_ROLES">
        <xsl:param name="datafield"></xsl:param>
        <xsl:choose>
            <xsl:when test="$datafield/p:subfield[@code='4']">

                <xsl:for-each select="$datafield/p:subfield[@code='4']">
                    <mods:role>
                        <xsl:if test="preceding-sibling::p:subfield[@code='B']">
                            <mods:roleTerm type="text" authority="GBV">
                                <xsl:value-of select="preceding-sibling::p:subfield[@code='B'][last()]" />
                            </mods:roleTerm>
                        </xsl:if>
                        <mods:roleTerm type="code" authority="marcrelator">
                            <xsl:value-of select="." />
                        </mods:roleTerm>
                    </mods:role>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$datafield/p:subfield[@code='B']">
                <mods:role>
                    <mods:roleTerm type="text" authority="GBV">
                        <xsl:value-of select="$datafield/p:subfield[@code='B']" />
                    </mods:roleTerm>
                </mods:role>
            </xsl:when>
            <xsl:when test="@tag='033J'">
                <mods:role>
                    <mods:roleTerm type="code" authority="marcrelator">pbl</mods:roleTerm>
                    <mods:roleTerm type="text" authority="GBV">Verlag</mods:roleTerm>
                </mods:role>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>
