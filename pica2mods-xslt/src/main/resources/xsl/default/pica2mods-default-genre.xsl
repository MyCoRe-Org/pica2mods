<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions" 
                xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="mods pica2mods">

  <xsl:import use-when="system-property('XSL_TESTING')='true'" href="_common/pica2mods-functions.xsl" />

  <!-- This template is for testing purposes -->
  <xsl:template match="p:record">
    <mods:mods>
      <xsl:call-template name="modsGenre" />
    </mods:mods>
  </xsl:template>

  <xsl:template name="modsGenre">
    <xsl:variable name="picaA" select="pica2mods:queryPicaDruck(.)" />
    <xsl:variable name="aadGenres" select="$picaA/p:datafield[@tag='044S'] | ./p:datafield[@tag='044S']" />
    <xsl:for-each-group select="$aadGenres/p:subfield[@code='a']" group-by=".">
      <mods:genre type="aadgenre">
        <xsl:value-of select="." />
      </mods:genre>
    </xsl:for-each-group>
  </xsl:template>

</xsl:stylesheet>
