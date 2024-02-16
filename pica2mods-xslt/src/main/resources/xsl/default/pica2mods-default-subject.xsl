<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="mods pica2mods p xlink fn"
                expand-text="yes">

  <xsl:import use-when="system-property('XSL_TESTING')='true'" href="_common/pica2mods-functions.xsl" />
  
  <xsl:param name="MCR.PICA2MODS.DATABASE" select="'k10plus'" />

  <!-- This template is for testing purposes -->
  <xsl:template match="p:record">
    <mods:mods>
      <xsl:call-template name="modsSubject" />
    </mods:mods>
  </xsl:template>

  <!-- TODO Wenn wir gegen den K10plus gehen bekommen wir hier die Schlagworte aller Bibliotheken ggf. auch mehrfach Sollte 
    man hier Filtern, dass nur die Schlagworte der "eigenen" Bibliothek ermittelt werden Problem dabei: Fehlende Struktur man 
    muss die relevanten Knoten über Nachfolger (Einstieg eigene Bibliothek 101@) und Vorgänger (nächster Bibliothekseinstieg 
    wieder 101@) ermitteln -->

  <xsl:template name="modsSubject">
    <!-- RVK Systematik aus 5090 (045R) -->
    <xsl:for-each select="./p:datafield[@tag='045R']/p:subfield[@code = '9']">
      <xsl:variable name="ppn" select="."/>

      <mods:subject authority="k10plus_field_5090" valueURI="https://uri.gbv.de/document/{$MCR.PICA2MODS.DATABASE}:ppn:{$ppn}">
        <xsl:variable name="subjects" select="pica2mods:queryPicaFromUnAPIWithPPN($MCR.PICA2MODS.DATABASE, $ppn)" />

        <xsl:for-each select="$subjects//p:datafield[@tag = '045A']">
          <mods:topic authority="rvk"
                      authorityURI="https://rvk.uni-regensburg.de/regensburger-verbundklassifikation-online"
                      valueURI="https://rvk.uni-regensburg.de/regensburger-verbundklassifikation-online#notation/{fn:encode-for-uri(fn:replace(p:subfield[@code = 'a'], '-', ' - '))}">
            <xsl:value-of select="fn:replace(p:subfield[@code = 'a'],'-',' - ')"/>
          </mods:topic>
          <!-- parent elements in RVK classification tree in 045C, currently ignored here -->
        </xsl:for-each>
      </mods:subject>
    </xsl:for-each>

    <!-- Schlagwörter aus einem Thesaurus und freie Schlagwörter 5520 (044N) (PPN 1818469049) -->
    <!-- erstmal nur Sachschlagworte (es gäbe auch Formschlagworte, Personen, Körperschaften, Geographika, Werktitel) -->
    <xsl:for-each select="./p:datafield[@tag='044N' and p:subfield[@code = 'S']/text() = 's' and p:subfield[@code = 'a']]">
      <mods:subject authority="k10plus_field_5520">
        <xsl:for-each select="./p:subfield[@code = 'a']">
          <mods:topic>
            <xsl:value-of select="."/>
          </mods:topic>
        </xsl:for-each>
      </mods:subject>
    </xsl:for-each>

    <!-- Lokale Schlagwörter aus 6500 (144Z) -->
    <xsl:for-each select="./p:datafield[@tag='144Z']"><!-- lokale Schlagworte -->
      <mods:subject authority="k10plus_field_6500">
        <xsl:if test="p:subfield[@code='9']">
          <xsl:attribute name="valueURI">https://uri.gbv.de/document/{$MCR.PICA2MODS.DATABASE}:ppn:{p:subfield[@code='9']}</xsl:attribute>
        </xsl:if>
        <!-- Ergänze ILN (internal library number) als Kommentar, um ggf. im Postprocessing darüber filtern zu können -->
        <xsl:text>&#xA;      </xsl:text>
        <xsl:comment>
          <xsl:value-of select="concat('[ILN: ',./preceding-sibling::p:datafield[@tag='101@'][1]/p:subfield[@code='a'], ']')" />
        </xsl:comment>
        <!-- Subfield x ist nicht in der Format-Dokumentation (PPN 898955750) -->
        <!-- kann mehrfach vorkommen -->
        <xsl:variable name="sf_x" select="./p:subfield[@code='x']" />
        <!-- TODO Es gibt hier auch (lokale) Normdatensätze mit PPN in $9 -> Werte aus Tx-Satz auslesen? -->
        <!-- Schlagwortketten mit " / " z.B. in Neubrandenburg (PPN: 1838831800) -->
        <xsl:for-each select="tokenize((./p:subfield[@code='a'])[1]/text(), ' / ')">
          <mods:topic>
            <xsl:choose>
              <xsl:when test="$sf_x">
                <xsl:value-of select="concat(., ' / ', string-join($sf_x,' / '))" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="." />
              </xsl:otherwise>
            </xsl:choose>
          </mods:topic>
        </xsl:for-each>
      </mods:subject>
    </xsl:for-each>

    <!-- Schlagwortfolgen (GBV, SWB, K10plus) auf bibliograpischer Ebene aus 5550 (044K)
         subfield 9 (GND auflösen), zusammengehörige Ketten über @occurrence="xx" erkennen
         Beispiel: ikar:ppn:100659853  -->
    <xsl:for-each-group select="./p:datafield[@tag='044K']" group-by="if (not(@occurrence)) then ('00') else (@occurrence)">
      <mods:subject authority="k10plus_field_555X">
        <xsl:for-each select="current-group()">
            <xsl:call-template name="processSubject" />
        </xsl:for-each>
      </mods:subject>
    </xsl:for-each-group>

    <!-- Schlagwortketten auf bibliograpischer Ebene aus 5100 (041A)
         subfield 9 (GND auflösen), zusammengehörige Ketten über 1. Position in @occurrence erkennen
         Beispiel: gvk:ppn:846106841  -->
    <xsl:for-each-group select="./p:datafield[@tag='041A']" group-by="if (not(@occurrence)) then ('0') else (substring(@occurrence,1,1))">
      <mods:subject authority="k10plus_field_51XX">
        <xsl:for-each select="current-group()">
          <!-- @occurrence x9 = Quelle -->
          <xsl:if test="not(ends-with(@occurrence, '9'))">
              <xsl:call-template name="processSubject" />
          </xsl:if>
        </xsl:for-each>
      </mods:subject>
    </xsl:for-each-group>

    <!-- Geokoordinaten und Maßstab aus 4028 (035G) und 4026 (035E)
         sowie menschenlesbare Form des Maßstabs als mods:note (035E $a)
         Beispiel: ikar:ppn:101493568  -->
    <xsl:variable name="scale" select="p:datafield[@tag='035E'][1]/p:subfield[@code='g']"/>
    <xsl:variable name="scaleHumanReadable" select="p:datafield[@tag='035E'][1]/p:subfield[@code='a']"/>
    <xsl:variable name="coords"
                  select="p:datafield[@tag='035G']/p:subfield[@code='a' or @code='b' or @code='c' or @code='d']"/>

    <xsl:if test="string-length($scale) &gt; 0 or count($coords) &gt; 0">
        <mods:subject authority="k10plus_field_4028">
            <mods:cartographics>
                <xsl:if test="string-length($scale) &gt; 0">
                    <mods:scale>
                        <xsl:value-of select="$scale"/>
                    </mods:scale>
                </xsl:if>
                <xsl:if test="count($coords)">
                    <xsl:variable name="a" select="p:datafield[@tag='035G']/p:subfield[@code='a']"/>
                    <xsl:variable name="b" select="p:datafield[@tag='035G']/p:subfield[@code='b']"/>
                    <xsl:variable name="c" select="p:datafield[@tag='035G']/p:subfield[@code='c']"/>
                    <xsl:variable name="d" select="p:datafield[@tag='035G']/p:subfield[@code='d']"/>
                    <mods:coordinates><xsl:value-of select="concat($a, $b, $c, $d)"/></mods:coordinates>
                </xsl:if>
            </mods:cartographics>
        </mods:subject>
    </xsl:if>
    <xsl:if test="string-length($scaleHumanReadable) &gt; 0">
      <mods:note type="cartographics_scale">
        <xsl:value-of select="$scaleHumanReadable"/>
      </mods:note>
    </xsl:if>

  </xsl:template>

  <!-- Hilfstemplate, um Unterfelder der verschiedenen Schlagwortfelder auszuwerten -->
  <xsl:template name="processSubject">
    <xsl:choose>
      <xsl:when test="p:subfield[@code='9']">
        <!-- Daten aus verknüpftem Normdatensatz übernehmen -->
        <xsl:call-template name="retrieveSubjectFromPPN">
          <xsl:with-param name="subjectPPN" select="p:subfield[@code='9']" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- Felder nur auswerten, wenn keine Normdatensatzverknüpfung vorliegt -->
        <xsl:if test="p:subfield[@code='a']">
          <mods:topic>
            <xsl:value-of select="p:subfield[@code='a']" />
          </mods:topic>
        </xsl:if>
        <xsl:if test="p:subfield[@code='g']">
          <mods:geographic>
            <xsl:value-of select="p:subfield[@code='g']" />
          </mods:geographic>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <!-- Zeitschlagworte kommen nie über die Normdatensatzverknüpfung -->
    <xsl:if test="p:subfield[@code='z']">
      <mods:temporal>
        <xsl:value-of select="p:subfield[@code='z']" />
      </mods:temporal>
    </xsl:if>
    <!-- Das Unterfeld $A (Einrichtung als Quelle des Schlagworts) ist nur in den Feldern 51X9 vorgesehen -->
  </xsl:template>

  <xsl:template name="retrieveSubjectFromPPN">
    <xsl:param name="subjectPPN" />
    <xsl:variable name="tp" select="pica2mods:queryPicaFromUnAPIWithPPN($MCR.PICA2MODS.DATABASE, $subjectPPN)" />
    <xsl:variable name="pica0500_2" select="substring($tp/p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
    <xsl:text>&#xA;      </xsl:text>
    <xsl:comment>
      <xsl:value-of select="concat('[PPN: ', $subjectPPN, ']')" />
    </xsl:comment>

    <xsl:variable name="elementName">
      <xsl:choose>
        <xsl:when test="$pica0500_2='g'">mods:geographic</xsl:when>
        <xsl:otherwise>mods:topic</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:element name="{$elementName}">
      <xsl:if test="$tp/p:datafield[@tag='003U']">
        <xsl:attribute name="authorityURI" select="'http://d-nb.info/gnd/'" />
        <xsl:attribute name="valueURI" select="$tp/p:datafield[@tag='003U']/p:subfield[@code='a']" />
        <xsl:attribute name="authority" select="'gnd'" />
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$tp/p:datafield[@tag='041A']"><xsl:value-of select="$tp/p:datafield[@tag='041A']/p:subfield[@code='a']" /></xsl:when>
        <xsl:when test="$tp/p:datafield[@tag='065A']"><xsl:value-of select="$tp/p:datafield[@tag='065A']/p:subfield[@code='a']" /></xsl:when>
        <xsl:when test="$tp/p:datafield[@tag='022A']"><xsl:value-of select="$tp/p:datafield[@tag='022A']/p:subfield[@code='a']" /></xsl:when>
        <xsl:when test="$tp/p:datafield[@tag='030A']"><xsl:value-of select="$tp/p:datafield[@tag='030A']/p:subfield[@code='a']" /></xsl:when>
        <xsl:when test="$tp/p:datafield[@tag='029A']"><xsl:value-of select="$tp/p:datafield[@tag='029A']/p:subfield[@code='a']" /></xsl:when>
        <xsl:when test="$tp/p:datafield[@tag='028A']">
          <!-- Person -->
          <xsl:variable name="firstName" select="$tp/p:datafield[@tag='028A']/p:subfield[@code='d']"/>
          <xsl:variable name="lastName" select="$tp/p:datafield[@tag='028A']/p:subfield[@code='a']"/>
          <xsl:variable name="nameAffix" select="$tp/p:datafield[@tag='028A']/p:subfield[@code='c']"/>
          <xsl:variable name="personalName" select="$tp/p:datafield[@tag='028A']/p:subfield[@code='5']"/>
          <!-- Ordnungshilfe-->
          <xsl:variable name="collocation" select="$tp/p:datafield[@tag='028A']/p:subfield[@code='l']"/>

          <xsl:choose>
            <xsl:when test="$personalName">
              <xsl:value-of select="$personalName"/>
              <xsl:if test="$collocation">
                <xsl:value-of select="concat(' &lt;',$collocation,'&gt;')"/>
              </xsl:if>
            </xsl:when>

            <xsl:when test="$firstName and $lastName and $collocation">
              <xsl:value-of select="concat($lastName,', ',$firstName,' &lt;',$collocation,'&gt;')"/>
            </xsl:when>

            <xsl:otherwise>
              <xsl:if test="$firstName and $lastName and $nameAffix">
                <xsl:value-of select="concat($lastName,', ',$firstName,' ',$nameAffix)"/>
              </xsl:if>

              <xsl:if test="$firstName and $lastName and not($nameAffix)">
                <xsl:value-of select="concat($lastName,', ',$firstName)"/>
              </xsl:if>

              <xsl:if test="$firstName and not($lastName or $nameAffix)">
                <xsl:value-of select="firstName"/>
              </xsl:if>

              <xsl:if test="not ($firstName) and $lastName">
                <xsl:value-of select="$lastName"/>
              </xsl:if>

              <xsl:if test="$firstName and not($lastName)">
                <xsl:value-of select="$firstName"/>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
