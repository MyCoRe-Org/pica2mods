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
    <xsl:if test="not(./p:datafield[@tag='017R'])">
      <xsl:for-each select="(./p:datafield[@tag='017C'][p:subfield[@code='x' and (starts-with(.,'D') or starts-with(.,'H'))]])[1]/p:subfield[@code='4']">
        <xsl:choose>
          <xsl:when test="./text()='LF'">
            <mods:accessCondition authority="k10plus_field_4950" type="restriction on access"
                xlink:href="http://purl.org/coar/access_right/c_abf2">Open Access</mods:accessCondition>
          </xsl:when>
          <xsl:when test="./text()='KW' or ./text()='NL'">
            <mods:accessCondition authority="k10plus_field_4950" type="restriction on access"
                xlink:href="http://purl.org/coar/access_right/c_f1cf">Embargoed Access</mods:accessCondition>
          </xsl:when>
          <xsl:when test="./text()='ZZ' or ./text()='EL' or ./text()='PU'">
            <mods:accessCondition authority="k10plus_field_4950" type="restriction on access"
                xlink:href="http://purl.org/coar/access_right/c_16ec">Restricted Access</mods:accessCondition>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
