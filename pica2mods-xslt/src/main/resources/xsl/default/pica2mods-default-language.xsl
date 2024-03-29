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
      <xsl:call-template name="modsLanguage" />
    </mods:mods>
  </xsl:template>

  <xsl:template name="modsLanguage">
    <!-- relative Pfade funktionieren nicht für Classpath-Resourcen: <xsl:variable name="rfc5646" select="document('../_common/rfc5646.xml')" -->
    <xsl:variable name="rfc5646" select="document('resource:mycore-classifications/rfc5646.xml')" />
    <xsl:for-each select="./p:datafield[@tag='010@']"> <!-- 1500 Language -->
      <!-- weiter Unterfelder für Orginaltext / Zwischenübersetzung nicht abbildbar -->
      <xsl:for-each select="./p:subfield[@code='a']">
        <mods:language>
            <xsl:variable name="l" select="." />
            <xsl:choose>
              <xsl:when test="$rfc5646/mycoreclass/categories//category[label[@xml:lang='x-bibl']/@text=$l]">
                <mods:languageTerm type="code" authority="rfc5646">
                  <xsl:value-of
                    select="$rfc5646/mycoreclass/categories//category[label[@xml:lang='x-bibl']/@text=$l]/@ID" />
                </mods:languageTerm>  
              </xsl:when>
              <xsl:otherwise>
                <xsl:comment>unknown language code</xsl:comment>
                <mods:languageTerm type="code">
                  <xsl:value-of select="." />
                </mods:languageTerm>
              </xsl:otherwise>
            </xsl:choose>
        </mods:language>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
