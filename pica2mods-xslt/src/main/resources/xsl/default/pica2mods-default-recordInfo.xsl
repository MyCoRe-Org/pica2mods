<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
                xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="mods pica2mods p xlink xs"
                expand-text="yes">

  <xsl:import use-when="system-property('XSL_TESTING')='true'" href="_common/pica2mods-functions.xsl" />
  
  <xsl:param name="MCR.PICA2MODS.DATABASE" select="'k10plus'" />

  <!-- This template is for testing purposes -->
  <xsl:template match="p:record">
    <mods:mods>
      <xsl:call-template name="modsRecordInfo" />
    </mods:mods>
  </xsl:template>

  <xsl:template name="modsRecordInfo">
    <xsl:variable name="picaMode" select="pica2mods:detectMode(.)" />
    <mods:recordInfo>
      <mods:recordIdentifier source="{$MCR.PICA2MODS.DATABASE}">
        <xsl:value-of select="./p:datafield[@tag='003@']/p:subfield[@code='0']" />
      </mods:recordIdentifier>
      <xsl:for-each select="./p:datafield[@tag='001A']/p:subfield[@code='0']"> <!-- 0200 Kennung und Datum der Ersterfassung -->
        <xsl:variable name="year" select="number(substring(.,string-length(.)-1,2))" />
        <mods:recordCreationDate encoding="w3cdtf">
          <xsl:value-of select="concat(if ($year > 69) then ('19') else ('20'),substring(.,string-length(.)-1,2),'-',substring(.,string-length(.)-4,2),'-',substring(.,string-length(.)-7,2))" />
        </mods:recordCreationDate>
      </xsl:for-each>
      <mods:recordChangeDate encoding="w3cdtf"><!-- use current timestamp -->
        <xsl:value-of select="format-dateTime(adjust-dateTime-to-timezone(current-dateTime(),xs:dayTimeDuration('PT0H')),'[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>
      </mods:recordChangeDate>
      <xsl:if test="./p:datafield[@tag='010E']/p:subfield[@code='e']/text()='rda'">
        <mods:descriptionStandard>rda</mods:descriptionStandard>
      </xsl:if>
      <mods:recordOrigin>
        Converted from PICA to MODS using {$MCR.PICA2MODS.CONVERTER_VERSION} in mode '{$picaMode}'.
      </mods:recordOrigin>
    </mods:recordInfo>
  </xsl:template>

</xsl:stylesheet>
