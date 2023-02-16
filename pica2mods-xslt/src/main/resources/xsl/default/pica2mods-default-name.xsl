<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions" 
                xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="mods pica2mods p xlink">

  <xsl:import use-when="system-property('XSL_TESTING')='true'" href="_common/pica2mods-functions.xsl" />
  
  <!-- This template is for testing purposes -->
  <xsl:param name="MCR.PICA2MODS.DATABASE" select="'k10plus'" />
  <xsl:template match="p:record">
    <mods:mods>
      <xsl:call-template name="modsName" />
    </mods:mods>
  </xsl:template>

  <xsl:template name="modsName">
    <xsl:call-template name="COMMON_PersonalName" />
    <xsl:call-template name="COMMON_CorporateName" />
  </xsl:template>

  <xsl:template name="COMMON_PersonalName">
    <!-- Lb: RDA, jetzt marcrelatorcode gemäß $4 bzw. ausgeschrieben $B -->
    <!-- 033J RAK: Drucker, Verleger bei Alten Drucken, in RDA nicht zugelassen -->
    <xsl:for-each select="./p:datafield[starts-with(@tag, '028') or @tag='033J']">
      <xsl:choose>
        <xsl:when test="./p:subfield[@code='9']">
          <xsl:variable name="ppn" select="./p:subfield[@code='9']" />
          <xsl:variable name="tp" select="pica2mods:queryPicaFromUnAPIWithPPN($MCR.PICA2MODS.DATABASE, $ppn)" />
          <xsl:if test="starts-with($tp/p:datafield[@tag='002@']/p:subfield[@code='0'], 'Tp')">
            <mods:name type="personal">
              <xsl:if test="$tp/p:datafield[@tag='028A']/p:subfield[@code='d']">
                <mods:namePart type="given">
                  <xsl:value-of select="$tp/p:datafield[@tag='028A']/p:subfield[@code='d']" />
                </mods:namePart>
              </xsl:if>
              <xsl:if test="$tp/p:datafield[@tag='028A']/p:subfield[@code='a']">
                <mods:namePart type="family">
                  <xsl:value-of select="$tp/p:datafield[@tag='028A']/p:subfield[@code='a']" />
                </mods:namePart>
              </xsl:if>
              <xsl:if test="$tp/p:datafield[@tag='028A']/p:subfield[@code='P']">
                <mods:namePart> <!-- Persönlicher Name -->
                  <xsl:value-of select="$tp/p:datafield[@tag='028A']/p:subfield[@code='P']" />
                </mods:namePart>
              </xsl:if>
              <xsl:if test="$tp/p:datafield[@tag='028A']/p:subfield[@code='c' or @code='n' or @code='l']">
                <mods:namePart type="termsOfAddress">
                  <xsl:value-of select="string-join($tp/p:datafield[@tag='028A']/p:subfield[@code='c' or @code='n' or @code='l'], ', ')" />
                </mods:namePart>
              </xsl:if>
              <xsl:for-each select="$tp/p:datafield[@tag='060R' and ./p:subfield[@code='4']='datl']">
                <xsl:if test="./p:subfield[@code='a']">
                  <xsl:variable name="out_date">
                    <xsl:value-of select="./p:subfield[@code='a']" />
                    -
                    <xsl:value-of select="./p:subfield[@code='b']" />
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
                <xsl:with-param name="datafield" select="." />
              </xsl:call-template>
              <xsl:if test="$tp/p:datafield[@tag='007K' and ./p:subfield[@code='a']='gnd']">
                <mods:nameIdentifier type="gnd">
                  <xsl:value-of
                    select="$tp/p:datafield[@tag='007K' and ./p:subfield[@code='a']='gnd']/p:subfield[@code='0']" />
                </mods:nameIdentifier>
              </xsl:if>
              <xsl:if test="$tp/p:datafield[@tag='006X' and ./p:subfield[@code='S']='orcid']">
                <mods:nameIdentifier type="orcid">
                  <xsl:value-of
                    select="$tp/p:datafield[@tag='006X' and ./p:subfield[@code='S']='orcid']/p:subfield[@code='0']" />
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
            <xsl:if test="./p:subfield[@code='P']">
              <mods:namePart>
                <xsl:value-of select="./p:subfield[@code='P']" />
              </mods:namePart>
            </xsl:if>
            
            <xsl:if test="./p:subfield[@code='c' or @code='n' or @code='l'] ">
              <mods:namePart type="termsOfAddress">
                <xsl:value-of select="string-join(./p:subfield[@code='c' or @code='n' or @code='l'], ', ')" />
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
                <xsl:value-of select="preceding-sibling::p:subfield[@code='B'][1]" />
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
              <xsl:when test="$datafield/p:subfield[@code='B']='Bearb.'">
                <xsl:text>ctb</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='Begr.'">
                <xsl:text>org</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='Hrsg.'">
                <xsl:text>edt</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='Ill.'">
                <xsl:text>ill</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='Komp.'">
                <xsl:text>cmp</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='Mitarb.'">
                <xsl:text>ctb</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='Red.'">
                <xsl:text>red</xsl:text>
              </xsl:when>
              <!-- GBV Katalogisierungsrichtlinie -->
              <xsl:when test="$datafield/p:subfield[@code='B']='Adressat'">
                <xsl:text>rcp</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='angebl. Hrsg.'">
                <xsl:text>edt</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='mutmaßl. Hrsg.'">
                <xsl:text>edt</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='Komm.'">
                <xsl:text>ann</xsl:text>
              </xsl:when><!-- Kommentator = annotator -->
              <xsl:when test="$datafield/p:subfield[@code='B']='Stecher'">
                <xsl:text>egr</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='angebl. Übers.'">
                <xsl:text>trl</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='mutmaßl. Übers.'">
                <xsl:text>trl</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='angebl. Verf.'">
                <xsl:text>dub</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='mutmaßl. Verf.'">
                <xsl:text>dub</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='Verstorb.'">
                <xsl:text>oth</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='Zeichner'">
                <xsl:text>drm</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='Präses'">
                <xsl:text>pra</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='Resp.'">
                <xsl:text>rsp</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='Widmungsempfänger'">
                <xsl:text>dto</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='Zensor'">
                <xsl:text>cns</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='Beiträger'">
                <xsl:text>ctb</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='Beiträger k.'">
                <xsl:text>ctb</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='Beiträger m.'">
                <xsl:text>ctb</xsl:text>
              </xsl:when>
              <xsl:when test="$datafield/p:subfield[@code='B']='Interpr.'">
                <xsl:text>prf</xsl:text>
              </xsl:when> <!-- Interpret = Performer -->
              <xsl:otherwise>
                <xsl:text>oth</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </mods:roleTerm>
          <mods:roleTerm type="text" authority="GBV">
            <xsl:value-of select="$datafield/p:subfield[@code='B']" />
          </mods:roleTerm>
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
        <mods:role>
          <mods:roleTerm type="code" authority="marcrelator">oth</mods:roleTerm>
        </mods:role>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="COMMON_CorporateName">
    <!--RAK 033J = 4033 Druckernormdaten, aber kein Ort angegeben (müsste aus GND gelesen werden) MODS unterstützt keine 
      authorityURIs für Verlage deshalb 033A verwenden , RDA: Drucker-/Verlegernormdaten als beteiligte Körperschaft in 3010/3110 
      mit entspr. Rollenbezeichnung -->
    <!-- Lb: RDA, jetzt marcrelatorcode gemäß $4 bzw. ausgeschrieben $B -->
    <!-- zusätzlich geprüft 033J = 4043 Druckernormadaten (alt) -->
    <xsl:for-each select="./p:datafield[starts-with(@tag, '029') or @tag='033J']">
      <xsl:choose>
        <!-- Normdatensatz vorhanden: -->
        <xsl:when test="./p:subfield[@code='9']">
          <xsl:variable name="ppn" select="./p:subfield[@code='9']" />
          <xsl:variable name="tb" select="pica2mods:queryPicaFromUnAPIWithPPN($MCR.PICA2MODS.DATABASE, $ppn)" />
          <xsl:choose>
            <xsl:when test="starts-with($tb/p:datafield[@tag='002@']/p:subfield[@code='0'], 'Tb')">
              <mods:name type="corporate">
                <xsl:if test="$tb/p:datafield[@tag='007K' and ./p:subfield[@code='a']='gnd']">
                  <mods:nameIdentifier type="gnd">
                    <xsl:value-of
                      select="$tb/p:datafield[@tag='007K' and ./p:subfield[@code='a']='gnd']/p:subfield[@code='0']" />
                  </mods:nameIdentifier>
                </xsl:if>
                <xsl:if test="$tb/p:datafield[@tag='029A']/p:subfield[@code='a']">
                  <mods:namePart>
                    <xsl:value-of select="$tb/p:datafield[@tag='029A']/p:subfield[@code='a']" />
                  </mods:namePart>
                </xsl:if>
                <xsl:if test="$tb/p:datafield[@tag='029A']/p:subfield[@code='b']">
                  <mods:namePart>
                    <xsl:value-of select="$tb/p:datafield[@tag='029A']/p:subfield[@code='b']" />
                  </mods:namePart>
                </xsl:if>
                <xsl:if test="$tb/p:datafield[@tag='029A']/p:subfield[@code='g']">
                  <mods:namePart>
                    <xsl:value-of select="$tb/p:datafield[@tag='029A']/p:subfield[@code='g']" />
                  </mods:namePart>
                </xsl:if>
                <xsl:if test="$tb/p:datafield[@tag='065A']/p:subfield[@code='a']">
                  <mods:namePart>
                    <xsl:value-of select="$tb/p:datafield[@tag='065A']/p:subfield[@code='a']" />
                  </mods:namePart>
                </xsl:if>
                <xsl:if test="$tb/p:datafield[@tag='065A']/p:subfield[@code='g']">
                  <mods:namePart>
                    <xsl:value-of select="$tb/p:datafield[@tag='065A']/p:subfield[@code='g']" />
                  </mods:namePart>
                </xsl:if>
  
                <xsl:for-each
                  select="$tb/p:datafield[@tag='060R' and (./p:subfield[@code='4']='datb' or ./p:subfield[@code='4']='datv')]">
                  <xsl:if test="./p:subfield[@code='a']">
                    <xsl:variable name="out_date">
                      <xsl:value-of select="./p:subfield[@code='a']" />
                      -
                      <xsl:value-of select="./p:subfield[@code='b']" />
                    </xsl:variable>
                    <mods:namePart type="date">
                      <xsl:value-of select="normalize-space($out_date)" />
                    </mods:namePart>
                  </xsl:if>
                  <xsl:if test="./p:subfield[@code='d']">
                    <mods:namePart type="date">
                      <xsl:value-of select="./p:subfield[@code='d']" />
                    </mods:namePart>
                  </xsl:if>
                </xsl:for-each>
                <xsl:call-template name="COMMON_CorporateName_ROLES">
                  <xsl:with-param name="datafield" select="." />
                </xsl:call-template>
              </mods:name>
            </xsl:when>
            <xsl:when test="starts-with($tb/p:datafield[@tag='002@']/p:subfield[@code='0'], 'Tf')">
              <mods:name type="conference">
                <xsl:if test="$tb/p:datafield[@tag='007K' and ./p:subfield[@code='a']='gnd']">
                  <mods:nameIdentifier type="gnd">
                    <xsl:value-of
                      select="$tb/p:datafield[@tag='007K' and ./p:subfield[@code='a']='gnd']/p:subfield[@code='0']" />
                  </mods:nameIdentifier>
                </xsl:if>
                <xsl:for-each select="$tb/p:datafield[@tag='030A']">
                  <mods:namePart>
                    <!-- Zählung -->
                    <xsl:if test="./p:subfield[@code='n']">
                      <xsl:variable name="num" select="./p:subfield[@code='n']" />
                      <xsl:value-of select="$num" />
                      <xsl:if test="not(ends-with($num,'.'))"><xsl:text>.</xsl:text></xsl:if>
                      <xsl:text> </xsl:text>
                    </xsl:if>
                    <!-- Hauptname -->
                    <xsl:if test="./p:subfield[@code='a']">
                      <xsl:value-of select="./p:subfield[@code='a']" />
                    </xsl:if>
                    <xsl:if test="./p:subfield[@code='g']">
                      <xsl:text> : </xsl:text>
                      <xsl:value-of select="./p:subfield[@code='g']" />
                    </xsl:if>
                    <!-- Untergeordnete Einheit -->
                    <xsl:if test="./p:subfield[@code='b']">
                      <xsl:text> ; </xsl:text>
                      <xsl:value-of select="./p:subfield[@code='b']" />
                    </xsl:if>
                    <!-- Datum / Ort -->
                    <xsl:if test="./p:subfield[@code='d' or @code='c']">
                      <xsl:text> (</xsl:text>
                      <!-- Ort -->
                      <xsl:if test="./p:subfield[@code='c']">
                       <xsl:value-of select="./p:subfield[@code='c']" />
                      </xsl:if>
                      <!-- Trenner -->
                      <xsl:if test="./p:subfield[@code='d'] and ./p:subfield[@code='d']">
                        <xsl:text>, </xsl:text>
                      </xsl:if>
                      <!-- Datum -->
                      <xsl:if test="./p:subfield[@code='d']">
                        <xsl:value-of select="./p:subfield[@code='d']" />
                      </xsl:if>

                      <xsl:text>)</xsl:text>
                    </xsl:if>
                  </mods:namePart>
                </xsl:for-each>
                <xsl:for-each select="$tb/p:datafield[@tag='060R' and ./p:subfield[@code='4']='datv']">
                <xsl:if test="./p:subfield[@code='a']">
                  <xsl:variable name="out_date">
                    <xsl:value-of select="./p:subfield[@code='a']" />
                    -
                    <xsl:value-of select="./p:subfield[@code='b']" />
                  </xsl:variable>
                  <mods:namePart type="date">
                    <xsl:value-of select="normalize-space($out_date)" />
                  </mods:namePart>
                </xsl:if>
                <xsl:if test="./p:subfield[@code='d']">
                  <mods:namePart type="date">
                    <xsl:value-of select="./p:subfield[@code='d']" />
                  </mods:namePart>
                </xsl:if>
                <xsl:if test="./p:subfield[@code='c']">
                  <mods:namePart type="date">
                    <xsl:value-of select="./p:subfield[@code='c']" />
                  </mods:namePart>
                </xsl:if>
              </xsl:for-each>
              
              <!-- Ort 
                  MODS Regelwerk:
                  <affiliation> may also contain other elements that are part of the affiliation, 
                  such as email address, street address, job title, etc.
                  (https://www.loc.gov/standards/mods/userguide/name.html#affiliation) -->
              <xsl:for-each select="$tb/p:datafield[@tag='065R' and ./p:subfield[@code='4']='ortv']">
                <mods:affiliation>
                  <xsl:choose>
                    <xsl:when test="./p:subfield[@code='9']">
                      <xsl:variable name="ppnOrt" select="./p:subfield[@code='9']" />
                      <xsl:variable name="tg" select="pica2mods:queryPicaFromUnAPIWithPPN($MCR.PICA2MODS.DATABASE, $ppnOrt)" />
                      <xsl:value-of select="$tg/p:datafield[@tag='065A']/p:subfield[@code='a']" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:if test="./p:subfield[@code='a']">
                        <xsl:value-of select="./p:subfield[@code='a']" />
                      </xsl:if>
                      <xsl:if test="./p:subfield[@code='g']">
                        <xsl:text> : </xsl:text>
                        <xsl:value-of select="./p:subfield[@code='g']" />
                      </xsl:if>
                      <xsl:for-each select="./p:subfield[@code='x']">
                        <xsl:text> / </xsl:text>
                        <xsl:value-of select="." />
                      </xsl:for-each>
                      <xsl:for-each select="./p:subfield[@code='z']">
                        <xsl:text> / </xsl:text>
                        <xsl:value-of select="." />
                      </xsl:for-each>
                    </xsl:otherwise>
                  </xsl:choose>
                </mods:affiliation>
                </xsl:for-each>    
                <xsl:call-template name="COMMON_CorporateName_ROLES">
                  <xsl:with-param name="datafield" select="." />
                </xsl:call-template>
              </mods:name>
            </xsl:when>  
          </xsl:choose>
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
            <xsl:if test="./p:subfield[@code='g']"> <!-- Zusatz -->
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
    
    <!-- 3160 / 030F Konferenz (andere Unterfelder als im Tf-Normdatensatz)-->
    <xsl:for-each select="./p:datafield[@tag='030F']">
      <mods:name type="conference">
        <mods:namePart>
          <!-- Zählung -->
          <xsl:if test="./p:subfield[@code='j']">
            <!-- Im Normdatensatz mit "." - hier ohne ? -->
            <xsl:variable name="num" select="./p:subfield[@code='j']" />
            <xsl:value-of select="$num" />
            <xsl:if test="not(ends-with($num,'.'))"><xsl:text>.</xsl:text></xsl:if>
            <xsl:text> </xsl:text>
          </xsl:if>
          <!-- Hauptname -->
          <xsl:if test="./p:subfield[@code='a']">
            <xsl:value-of select="./p:subfield[@code='a']" />
          </xsl:if>
          <!-- Untergeordnete Einheit -->
          <xsl:if test="./p:subfield[@code='b']">
            <xsl:text> ; </xsl:text>
            <xsl:value-of select="./p:subfield[@code='b']" />
          </xsl:if>
          <!-- Datum / Ort -->
          <xsl:if test="./p:subfield[@code='k' or @code='p']">
            <xsl:text> (</xsl:text>
            <!-- Ort -->
            <xsl:if test="./p:subfield[@code='k']">
              <xsl:value-of select="./p:subfield[@code='k']" />
            </xsl:if>
            <!-- Trenner -->
            <xsl:if test="./p:subfield[@code='k'] and ./p:subfield[@code='p']">
              <xsl:text>, </xsl:text>
            </xsl:if>
            <!-- Datum -->
            <!-- hier in normierter Form
            Jahr. / Jahr.-Jahr. / Jahr.Monat. / Jahr.Monat.-Jahr.Monat. / Jahr.Monat.-Monat.
            Jahr.Monat.Tag / Jahr.Monat.Tag-Tag / Jahr.Monat.Tag-Monat.Tag / Jahr.Monat.Tag-Jahr.Monat.Tag 
            -->
            <xsl:if test="./p:subfield[@code='p']">
              <xsl:call-template name="conference_date_from3160">
                  <xsl:with-param name="date" select="./p:subfield[@code='p']" />
              </xsl:call-template>
            </xsl:if>
            <xsl:text>)</xsl:text>
          </xsl:if>
        </mods:namePart>
        <!-- erstmal keine Rolle für diesen Fall, eine Option wäre:
        <mods:role>
          <mods:roleTerm type="code" authority="marcrelator">orm</mods:roleTerm>
          <mods:roleTerm type="text" authority="GBV">VeranstalterIn</mods:roleTerm>
        </mods:role>
        -->
      </mods:name>
     </xsl:for-each>
  </xsl:template>

  <xsl:template name="conference_date_from3160">
    <xsl:param name="date" />
    <!-- mögliche Datumsformate gem. Formatdokumentation:
         Jahr.
         Jahr.-Jahr.
         Jahr.Monat.
         Jahr.Monat.-Jahr.Monat.
         Jahr.Monat.-Monat.
         Jahr.Monat.Tag
         Jahr.Monat.Tag-Tag
         Jahr.Monat.Tag-Monat.Tag
         Jahr.Monat.Tag-Jahr.Monat.Tag
         (https://format.k10plus.de/k10plushelp.pl?cmd=kat&val=3160&katalog=Standard)
    -->
    <xsl:choose>
      <xsl:when test="matches($date, '\d\d\d\d\.\d\d\.\d\d\-\d\d.\d\d')">
        <xsl:variable name="year" select="substring($date,1,4)"/>
        <xsl:value-of select="concat(substring($date,6,2), '.', substring($date,9,2), '.', $year, '-', substring($date,12,2), '.', substring($date,15,2), '.', $year)" />
      </xsl:when>
      <xsl:when test="matches($date, '\d\d\d\d\.\d\d\.\d\d')">
        <xsl:value-of select="concat(substring($date,9,2),'.',substring($date,6,2),'.',substring($date,1,4))" />
      </xsl:when>
      <xsl:when test="matches($date, '\d\d\d\d\.\d\d\.\d\d\-\d\d')">
        <xsl:value-of select="concat(substring($date,9,5),'.',substring($date,6,2),'.',substring($date,1,4))" />
      </xsl:when>
      <!-- ToDo andere Fälle bei Bedarf -->
      <xsl:otherwise>
        <xsl:value-of select="$date" />
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>  

  <xsl:template name="COMMON_CorporateName_ROLES">
    <xsl:param name="datafield"></xsl:param>
    <xsl:choose>
      <xsl:when test="$datafield/p:subfield[@code='4']">

        <xsl:for-each select="$datafield/p:subfield[@code='4']">
          <mods:role>
            <xsl:if test="preceding-sibling::p:subfield[@code='B']">
              <mods:roleTerm type="text" authority="GBV">
                <xsl:value-of select="preceding-sibling::p:subfield[@code='B'][1]" />
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
