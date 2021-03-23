<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="mods pica2mods"
                expand-text="yes">

  <xsl:import use-when="system-property('XSL_TESTING')='true'" href="_common/pica2mods-functions.xsl" />

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
    <xsl:for-each select="./p:datafield[@tag='144Z' and @occurrence]"><!-- lokale Schlagworte -->
      <mods:subject>
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
  </xsl:template>

</xsl:stylesheet>
