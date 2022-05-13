<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="mods pica2mods p xlink"
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
    <!-- Schlagwortketten auf lokaler Ebene aus 6500 (144Z) -->
    <xsl:for-each select="./p:datafield[@tag='144Z' and @occurrence]"><!-- lokale Schlagworte -->
      <mods:subject authority="k10plus_field_6500">
        <!-- Subfield x ist nicht in der Format-Dokumentation (PPN 898955750) -->
        <!-- kann mehrfach vorkommen -->
        <xsl:variable name="sf_x" select="./p:subfield[@code='x']" />
        <!-- TODO Schlagwortketten mit " / " habe ich in Rostock nicht gefunden -->
        <xsl:for-each select="tokenize(./p:subfield[@code='a']/text(), ' / ')">
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

    <!-- Schlagwortketten auf bibliograpischer Ebene aus 6400 (044K) 
         subfield 9 (GND auflösen), zusammengehörige Ketten über @occurrence="xx" erkennen
         Beispiel: ikar:ppn:100659853  -->
    <xsl:for-each-group select="./p:datafield[@tag='044K']" group-by="if (not(@occurrence)) then ('00') else (@occurrence)">
      <mods:subject authority="k10plus_field_6400">
        <xsl:for-each select="current-group()">
            <xsl:choose>
              <xsl:when test="p:subfield[@code='9']">
                <xsl:call-template name="getSubjectFromPPN">
                  <xsl:with-param name="subjectPPN" select="p:subfield[@code='9']" />
                </xsl:call-template>
              </xsl:when>
              <xsl:when test="p:subfield[@code='a']">
                <mods:topic>
                  <xsl:value-of select="p:subfield[@code='a']" />
                </mods:topic>
              </xsl:when>
              <xsl:when test="p:subfield[@code='A']">
                <mods:topic>
                  <xsl:value-of select="p:subfield[@code='A']" />
                </mods:topic>
              </xsl:when>
            </xsl:choose>
        </xsl:for-each>
      </mods:subject>
    </xsl:for-each-group>

  </xsl:template>
  
  
  <xsl:template name="getSubjectFromPPN">
    <xsl:param name="subjectPPN" />
    <xsl:variable name="tp" select="pica2mods:queryPicaFromUnAPIWithPPN($MCR.PICA2MODS.DATABASE, $subjectPPN)" />
    <mods:topic>
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
            <xsl:value-of select="$tp/p:datafield[@tag='028A']/p:subfield[@code='a']" />, <xsl:value-of select="$tp/p:datafield[@tag='028A']/p:subfield[@code='b']" />
        </xsl:when>
      </xsl:choose>
    </mods:topic>
  </xsl:template>

</xsl:stylesheet>
