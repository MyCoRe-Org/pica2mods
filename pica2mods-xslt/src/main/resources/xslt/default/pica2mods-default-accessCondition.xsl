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
      <xsl:call-template name="modsAccessCondition" />
    </mods:mods>
  </xsl:template>

  <xsl:template name="modsAccessCondition">
    <!-- 4980 Rechteinformation -->
    <xsl:for-each select="./p:datafield[@tag='017M']">
      <xsl:if test="p:subfield[@code='b']">
        <xsl:text>&#xA;      </xsl:text>
        <xsl:comment>
          <xsl:value-of select="concat('[Source: ', p:subfield[@code='b'], ']')" />
        </xsl:comment>
      </xsl:if>
      <mods:accessCondition authority="k10plus_field_4980" type="use and reproduction">
        <xsl:if test="./p:subfield[@code='u']">
          <xsl:attribute name="xlink:href" select="./p:subfield[@code='u']" />
        </xsl:if>
        <xsl:value-of select="./p:subfield[@code='a']" />
        <xsl:if test="./p:subfield[@code='c']">
           <xsl:value-of select="concat(' [', ./p:subfield[@code='c'], ']')" />
        </xsl:if>
      </mods:accessCondition>
    </xsl:for-each>
    <!-- 4985 AccessStatus -->
    <xsl:for-each select="./p:datafield[@tag='017R']">
      <xsl:if test="p:subfield[@code='b']">
        <xsl:text>&#xA;      </xsl:text>
        <xsl:comment>
          <xsl:value-of select="concat('[Source: ', p:subfield[@code='b'], ']')" />
        </xsl:comment>
      </xsl:if>
      <mods:accessCondition authority="k10plus_field_4985" type="restriction on access">
        <xsl:if test="./p:subfield[@code='u']">
          <xsl:attribute name="xlink:href" select="./p:subfield[@code='u']" />
        </xsl:if>
        <xsl:value-of select="./p:subfield[@code='a']" />
      </mods:accessCondition>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
