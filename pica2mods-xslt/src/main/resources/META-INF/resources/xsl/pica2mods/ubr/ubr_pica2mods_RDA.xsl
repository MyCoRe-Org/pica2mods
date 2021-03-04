<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="p xalan fn">
  <xsl:import href="cp:ubr/ubr_pica2mods_common.xsl" />
  
  <xsl:variable name="XSL_VERSION_RDA" select="concat('ubr_pica2mods_RDA.xsl from ',$XSL_VERSION_PICA2MODS)" />
  <xsl:template match="/p:record" mode="RDA">
    <xsl:variable name="ppnA" select="./p:datafield[@tag='039I']/p:subfield[@code='9'][1]/text()" />
    <xsl:variable name="zdbA" select="./p:datafield[@tag='039I']/p:subfield[@code='C' and text()='ZDB']/following-sibling::p:subfield[@code='6'][1]/text()" />
    <xsl:variable name="pica0500_2" select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />



  </xsl:if>
    <!-- Wenn 0500 2. Pos ='v', 
       dann originInfo[@eventtype='creation'] aus O-Aufnahmen-Feldern:
        - publisher und placeTerm nicht vorhanden (keine Av-Stufe vorhanden)
        - datesissued aus 011@ $r
        - issuance -> Konstante "serial" -->
    
    
      <!-- Vorgänger, Nachfolger Verknüpfung ZDB -->
      <xsl:if test="$pica0500_2='b'">
        <xsl:for-each select="./p:datafield[@tag='039E' and (./p:subfield[@code='b' and text()='f'] or ./p:subfield[@code='b'and text()='s'])]"><!-- 4244 -->
          <mods:relatedItem>
            <xsl:if test="./p:subfield[@code='b' and text()='f']">
              <xsl:attribute name="type">preceding</xsl:attribute>
            </xsl:if>
            <xsl:if test="./p:subfield[@code='b' and text()='s']">
              <xsl:attribute name="type">succeeding</xsl:attribute>
            </xsl:if>
           <xsl:if test="./p:subfield[@code='t']">
              <mods:titleInfo>
                <mods:title>
                  <xsl:value-of select="./p:subfield[@code='t']" />
                </mods:title>
              </mods:titleInfo>
           </xsl:if>
           <xsl:if test="./p:subfield[@code='C' and text()='ZDB']">
            <mods:identifier type="zdb">
              <xsl:value-of select="./p:subfield[@code='C' and text()='ZDB']/following-sibling::p:subfield[@code='6'][1]"></xsl:value-of>
            </mods:identifier>
           </xsl:if>
          </mods:relatedItem>
        </xsl:for-each>
      </xsl:if>
  </xsl:template>

</xsl:stylesheet> 