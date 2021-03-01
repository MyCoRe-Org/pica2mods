<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="3.0"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
                exclude-result-prefixes="mods pica2mods">

  <xsl:import use-when="system-property('XSL_TESTING')='true'" href="_common/pica2mods-functions.xsl" />

  <!-- This template is for testing purposes -->
  <xsl:template match="p:record">
    <mods:mods>
      <xsl:call-template name="modsRecordInfo" />
    </mods:mods>
  </xsl:template>

  <xsl:template name="modsRecordInfo">
    <mods:recordInfo>
      <mods:recordIdentifier source="{$MCR.PICA2MODS.DATABASE}">
        <xsl:value-of select="concat('',./p:datafield[@tag='003@']/p:subfield[@code='0'])" />
      </mods:recordIdentifier>
      <xsl:if test="./p:datafield[@tag='010E']/p:subfield[@code='e']/text()='rda'">
        <mods:descriptionStandard>rda</mods:descriptionStandard>
      </xsl:if>
      <mods:recordOrigin>
        <xsl:value-of
          select="normalize-space(concat('Converted from PICA to MODS using ',$MCR.PICA2MODS.CONVERTER_VERSION))" />
      </mods:recordOrigin>
    </mods:recordInfo>
  </xsl:template>

</xsl:stylesheet>
