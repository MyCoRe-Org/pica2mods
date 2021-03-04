<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xalan="http://xml.apache.org/xalan" xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:p="info:srw/schema/5/picaXML-v1.0" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="p xalan fn">
  <xsl:import href="cp:ubr/ubr_pica2mods_common.xsl" />
  <xsl:variable name="XSL_VERSION_KXP" select="concat('ubr_pica2mods_KXP.xsl from ',$XSL_VERSION_PICA2MODS)" />
  <xsl:template match="/p:record" mode="KXP">
  	<xsl:variable name="ppnA" select="./p:datafield[@tag='039D'][./p:subfield[@code='C']='GBV']/p:subfield[@code='6']/text()" />
	<xsl:variable name="pica0500_2" select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
  <xsl:if test="$ppnA">
    	<mods:note type="PPN-A"><xsl:value-of select="$ppnA" /></mods:note>
    </xsl:if> 
        <mods:physicalDescription>
          <xsl:for-each select="./p:datafield[@tag='034D']/p:subfield[@code='a']">   <!--  4060 Umfang, Seiten -->
            <mods:extent><xsl:value-of select="." /></mods:extent>
          </xsl:for-each>
          <xsl:for-each select="./p:datafield[@tag='034M']/p:subfield[@code='a']">   <!--  4061 Illustrationen -->
              <mods:extent><xsl:value-of select="." /></mods:extent>
          </xsl:for-each>
          <xsl:for-each select="./p:datafield[@tag='034I']/p:subfield[@code='a']">   <!-- 4062 Format, Größe  -->
              <mods:extent><xsl:value-of select="." /></mods:extent>
          </xsl:for-each>
          <xsl:for-each select="./p:datafield[@tag='034K']/p:subfield[@code='a']">   <!-- 4063 Begleitmaterial  -->
              <mods:extent><xsl:value-of select="." /></mods:extent>
          </xsl:for-each>
          
          <xsl:choose> <!-- 4238 Technische Angaben zum elektr. Dokument  -->
            <xsl:when test="contains(./p:datafield[@tag='037H']/p:subfield[@code='a'], 'Digitalisierungsvorlage: Original')"> <!-- alt -->
                <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
            </xsl:when>
            <xsl:when test="contains(./p:datafield[@tag='037H']/p:subfield[@code='a'], 'Digitalisierungsvorlage: Primärausgabe')">
                <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
            </xsl:when>
            <xsl:when test="contains(./p:datafield[@tag='037H']/p:subfield[@code='a'], 'Digitalisierungsvorlage: Mikrofilm')">
                <mods:digitalOrigin>digitized microfilm</mods:digitalOrigin>
            </xsl:when>
            <xsl:otherwise>
             	<mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
          	</xsl:otherwise>
		  </xsl:choose>
          
        </mods:physicalDescription>
        
         <xsl:for-each select="./p:datafield[@tag='044S']"> <!-- 5570 Gattungsbegriffe AAD -->
          <mods:genre type="aadgenre"><xsl:value-of select="./p:subfield[@code='a']"/></mods:genre>
          <xsl:call-template name="COMMON_UBR_Class_AADGenres" />
         </xsl:for-each>     
  
        <xsl:for-each select="./p:datafield[@tag='017H']"> <!-- 4961 URL für sonstige Angaben zur Resource -->
          <mods:note type="source note">
            <xsl:attribute name="xlink:href"><xsl:value-of select="./p:subfield[@code='u']" /></xsl:attribute>
            <xsl:value-of select="./p:subfield[@code='y']" />
          </mods:note>
        </xsl:for-each>
    

      <xsl:for-each select="./p:datafield[@tag='037G']"> <!-- 4237 Anmerkungen zur Reproduktion -->
        <mods:note type="reproduction">
          <xsl:value-of select="./p:subfield[@code='a']" />
        </mods:note>
      </xsl:for-each>
      
      <xsl:for-each select="./p:datafield[@tag='037A' or @tag='037B' or @tag='046L' or @tag='046F' or @tag='046G' or @tag='046H' or @tag='046I' or @tag='046P']"><!-- 4201, 4202, 4221, 4215, 4216, 4217, 4218 RDA raus 4202, 4215, 4216 neu 4210, 4212, 4221, 4223, 4225, 4226 (einfach den ganzen Anmerkungskrams mitnehmen)" -->
          <mods:note type="source note"><xsl:value-of select="./p:subfield[@code='a']" /></mods:note>
      </xsl:for-each>
      
      <xsl:for-each select="./p:datafield[@tag='047C']"><!-- 4200 -->
          <mods:note type="titlewordindex"><xsl:value-of select="./p:subfield[@code='a']" /></mods:note>
      </xsl:for-each>
      
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