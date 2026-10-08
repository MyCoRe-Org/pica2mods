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
  <xsl:template match="p:record">
    <mods:mods>
      <xsl:call-template name="modsLocation" />
    </mods:mods>
  </xsl:template>

  <xsl:template name="modsLocation">
    <!-- 4065 Besitznachweis der Vorlage -->
    <xsl:for-each select="./p:datafield[@tag='009A']">
      <mods:location>
        <xsl:if test="./p:subfield[@code='c']">
          <xsl:choose>
            <xsl:when
              test="./p:subfield[@code='c']='UB Rostock' or ./p:subfield[@code='c']='Universitätsbibliothek Rostock'">
              <mods:physicalLocation type="current" authorityURI="http://d-nb.info/gnd/"
                valueURI="http://d-nb.info/gnd/25968-8">Universitätsbibliothek Rostock</mods:physicalLocation>
            </xsl:when>
            <xsl:otherwise>
              <mods:physicalLocation type="current">
                <xsl:value-of select="./p:subfield[@code='c']" />
              </mods:physicalLocation>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:if test="./p:subfield[@code='a']">
          <mods:shelfLocator>
            <xsl:value-of select="./p:subfield[@code='a']" />
          </mods:shelfLocator>
        </xsl:if>
      </mods:location>
    </xsl:for-each>
    <!-- 4950 URL zum Volltext -->
    <xsl:for-each select="./p:datafield[@tag='017C'][p:subfield[@code='x' and (starts-with(.,'D') or starts-with(.,'H'))]]">
      <mods:location>
        <mods:url access="object in context">
          <xsl:variable name="avail_vol" select="substring-after(./p:subfield[@code='x'],'; ')" />
          <xsl:if test="string-length($avail_vol) &gt; 0">
            <xsl:attribute name="note" select="$avail_vol" />
          </xsl:if>
          <xsl:value-of select="./p:subfield[@code='u']" />
        </mods:url>
      </mods:location>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
