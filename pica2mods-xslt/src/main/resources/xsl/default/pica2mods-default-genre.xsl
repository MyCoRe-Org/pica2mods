<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions" 
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
      <xsl:call-template name="modsGenre" />
    </mods:mods>
  </xsl:template>

  <xsl:template name="modsGenre">
    <xsl:for-each select="./p:datafield[@tag='013D']"><!-- 1131 Art des Inhalts -->
      <xsl:variable name="genre_obj"
        select="pica2mods:queryPicaFromUnAPIWithPPN($MCR.PICA2MODS.DATABASE, ./p:subfield[@code='9'])" />
      <xsl:element name="mods:genre">
        <xsl:attribute name="type">nature_of_content</xsl:attribute>
        <xsl:attribute name="displayLabel">natureOfContent</xsl:attribute>
        <xsl:attribute name="authorityURI">
                <xsl:value-of select="'http://www.mycore.org/classifications/natureOfContent'" />
              </xsl:attribute>
        <xsl:attribute name="valueURI">
                <xsl:value-of
          select="concat('http://www.mycore.org/classifications/natureOfContent#ppn_',$genre_obj/p:datafield[@tag='003@']/p:subfield[@code='0'])" />
              </xsl:attribute>
        <xsl:value-of select="$genre_obj/p:datafield[@tag='041A']/p:subfield[@code='a']" />
      </xsl:element>
    </xsl:for-each>

    <xsl:variable name="picaA" select="pica2mods:queryPicaDruck(.)" /><!-- 5570 Gattungsbegriffe bei Alten Drucken -->
    <xsl:variable name="aadGenres" select="$picaA/p:datafield[@tag='044S'] | ./p:datafield[@tag='044S']" />
    <xsl:for-each-group select="$aadGenres/p:subfield[@code='9']" group-by=".">
      <xsl:variable name="genre_obj" select="pica2mods:queryPicaFromUnAPIWithPPN('k10plus', .)" />
      <xsl:element name="mods:genre">
        <xsl:attribute name="type">aadgenre</xsl:attribute>
        <xsl:attribute name="displayLabel">aadgenre</xsl:attribute>
        <xsl:attribute name="authorityURI">
                <xsl:value-of select="'http://www.mycore.org/classifications/aadgenres'" />
              </xsl:attribute>
        <xsl:attribute name="valueURI">
                <xsl:value-of
          select="concat('http://www.mycore.org/classifications/aadgenres#ppn_',$genre_obj/p:datafield[@tag='003@']/p:subfield[@code='0'])" />
              </xsl:attribute>
        <xsl:value-of select="$genre_obj/p:datafield[@tag='041A']/p:subfield[@code='a']" />
      </xsl:element>
    </xsl:for-each-group>
  </xsl:template>


</xsl:stylesheet>
