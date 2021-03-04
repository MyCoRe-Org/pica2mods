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

    <!-- Titel fingiert, wenn kein Titel in 4000 -->
    <xsl:choose>
      <xsl:when test="$pica0500_2='f' or $pica0500_2='F' ">
        <xsl:for-each select="./p:datafield[@tag='036C']"><!-- 4150 -->
          <xsl:call-template name="COMMON_Title" />
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$pica0500_2='v' and ./p:datafield[@tag='036F']">
        <xsl:for-each select="./p:datafield[@tag='036F']"><!-- 4180 -->
          <xsl:call-template name="COMMON_Title" />
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="./p:datafield[@tag='021A']"> <!-- 4000 -->
          <xsl:call-template name="COMMON_Title" />
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    
      <!--  Titel fingiert, wenn kein Titel in 4000 --> 
     <xsl:call-template name="COMMON_Alt_Uniform_Title" />
      
      <xsl:for-each select="./p:datafield[@tag='010@']"> <!-- 1500 Language -->
      <!-- weiter Unterfelder für Orginaltext / Zwischenübersetzung nicht abbildbar -->
        <xsl:for-each select="./p:subfield[@code='a']">
          <mods:language>
             <mods:languageTerm type="code" authority="iso639-2b"><xsl:value-of select="." /></mods:languageTerm>
          </mods:language>
        </xsl:for-each>
      </xsl:for-each>
      
      <xsl:for-each select="./p:datafield[@tag='039B']"> <!-- 4241  übergeordnetes Werk-->
        <xsl:call-template name="COMMON_AppearsIn" />
      </xsl:for-each>
    
      <xsl:for-each select="./p:datafield[@tag='036D']"> <!-- 4160  übergeordnetes Werk-->
        <xsl:call-template name="COMMON_HostOrSeries" />
      </xsl:for-each>

      <!--TODO: Unterscheidung nach 0500 2. Pos: wenn 'v' dann type->host, sonst type->series -->
      <xsl:for-each select="./p:datafield[@tag='036F']"> <!-- 4180  Schriftenreihe, Zeitschrift-->
        <xsl:call-template name="COMMON_HostOrSeries" />
      </xsl:for-each>
      
      <xsl:for-each select="./p:datafield[@tag='039P']"> <!-- 4261  RezensiertesWerk-->
          <xsl:call-template name="COMMON_Review" />
      </xsl:for-each>

      <!-- check use of eventtype attribute -->
          <mods:originInfo eventType="creation">
            <xsl:for-each select="./p:datafield[@tag='033A']">
              <xsl:if test="./p:subfield[@code='n']">  <!-- 4030 Ort, Verlag -->
                 <mods:publisher><xsl:value-of select="./p:subfield[@code='n']" /></mods:publisher>
              </xsl:if>
              <xsl:for-each select="./p:subfield[@code='p']">
                <mods:place><mods:placeTerm type="text"><xsl:value-of select="." /></mods:placeTerm></mods:place>
              </xsl:for-each>
            </xsl:for-each>
            <!-- normierte Orte 4040, außer Hochschulort $4=uvp -->
            <xsl:for-each select="./p:datafield[@tag='033D' and not(./p:subfield[@code='4']='uvp')]">
              <mods:place supplied="yes">
               <mods:placeTerm lang="ger" type="text">
               <xsl:choose>
                <xsl:when test="./p:subfield[@code='8']">
                    <xsl:value-of select="./p:subfield[@code='8']" />
                </xsl:when>
                <xsl:otherwise> 
                    <xsl:value-of select="./p:subfield[@code='p']" />
                </xsl:otherwise>
               </xsl:choose>
               </mods:placeTerm>
             </mods:place>
        </xsl:for-each>
        
        <xsl:for-each select="./p:datafield[@tag='011@']">
          <xsl:choose>
            <xsl:when test="./p:subfield[@code='b']">
              <mods:dateIssued keyDate="yes" encoding="iso8601" point="start">
                <xsl:value-of select="./p:subfield[@code='a']" />
              </mods:dateIssued>
              <mods:dateIssued encoding="iso8601" point="end">
                <xsl:value-of select="./p:subfield[@code='b']" />
              </mods:dateIssued>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="contains(./p:subfield[@code='a'], 'X')">
                  <mods:dateIssued keyDate="yes" encoding="iso8601" point="start">
                    <xsl:value-of select="translate(./p:subfield[@code='a'], 'X','0')" />
                  </mods:dateIssued>
                  <mods:dateIssued encoding="iso8601" point="end">
                    <xsl:value-of select="translate(./p:subfield[@code='a'], 'X', '9')" />
                  </mods:dateIssued>
                </xsl:when>
                <xsl:otherwise>
                  <mods:dateIssued keyDate="yes" encoding="iso8601">
                    <xsl:value-of select="./p:subfield[@code='a']" />
                  </mods:dateIssued>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="./p:subfield[@code='n']">
            <mods:dateIssued qualifier="approximate">
              <xsl:value-of select="./p:subfield[@code='n']" />
            </mods:dateIssued>
        </xsl:if>
        </xsl:for-each>              

            <xsl:for-each select="./p:datafield[@tag='032@']"> <!-- 4020 Ausgabe-->
              <xsl:choose>
                 <xsl:when test="./p:subfield[@code='h']">
                   <mods:edition><xsl:value-of select="./p:subfield[@code='a']" /> / <xsl:value-of select="./p:subfield[@code='h']" /></mods:edition>
                  </xsl:when>
                  <xsl:otherwise>
                      <mods:edition><xsl:value-of select="./p:subfield[@code='a']" /></mods:edition>
                  </xsl:otherwise>   
              </xsl:choose>
            </xsl:for-each>

              <xsl:choose>
                 <xsl:when test="$pica0500_2='a'"><mods:issuance>monographic</mods:issuance></xsl:when>
                 <xsl:when test="$pica0500_2='b'"><mods:issuance>serial</mods:issuance></xsl:when>
                 <xsl:when test="$pica0500_2='c'"><mods:issuance>multipart monograph</mods:issuance></xsl:when>
                 <xsl:when test="$pica0500_2='d'"><mods:issuance>serial</mods:issuance></xsl:when>
                 <xsl:when test="$pica0500_2='f'"><mods:issuance>monographic</mods:issuance></xsl:when>
                 <xsl:when test="$pica0500_2='F'"><mods:issuance>monographic</mods:issuance></xsl:when>
                 <xsl:when test="$pica0500_2='j'"><mods:issuance>single unit</mods:issuance></xsl:when>
                 <xsl:when test="$pica0500_2='s'"><mods:issuance>single unit</mods:issuance></xsl:when>
                 <xsl:when test="$pica0500_2='v'"><mods:issuance>serial</mods:issuance></xsl:when>                     
              </xsl:choose>              
          </mods:originInfo>

         <xsl:for-each select="./p:datafield[@tag='009A']"> <!-- 4065 Besitznachweis der Vorlage-->
           <mods:location>
              <xsl:if test="./p:subfield[@code='c']">
                <xsl:choose>
                 <xsl:when test="./p:subfield[@code='c']='UB Rostock'">
                   <mods:physicalLocation type="current" authorityURI="http://d-nb.info/gnd/" valueURI="http://d-nb.info/gnd/25968-8">Universitätsbibliothek Rostock</mods:physicalLocation>
                  </xsl:when>
                  <xsl:otherwise>
                      <mods:physicalLocation type="current"><xsl:value-of select="./p:subfield[@code='c']" /></mods:physicalLocation>
                  </xsl:otherwise>   
                </xsl:choose>
             </xsl:if>
             <xsl:if test="./p:subfield[@code='a']">
                <mods:shelfLocator><xsl:value-of select="./p:subfield[@code='a']" /></mods:shelfLocator>
             </xsl:if>
           </mods:location>
        </xsl:for-each>

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
        
       <mods:originInfo eventType="online_publication">
         <!--wenn keine 4031, dann aus 4048/033N -->
         <!--hier mehrere digitalisierende Einrichtungen for each-->
         <xsl:for-each select="./p:datafield[@tag='033B' or @tag='033N']"> <!-- 4031 Ort, Verlag -->
             <xsl:if test="./p:subfield[@code='n']">
                 <mods:publisher><xsl:value-of select="./p:subfield[@code='n']" /></mods:publisher>
             </xsl:if>
             <xsl:if test="./p:subfield[@code='p']">
                <mods:place><mods:placeTerm type="text"><xsl:value-of select="./p:subfield[@code='p']" /></mods:placeTerm></mods:place>
             </xsl:if>
           </xsl:for-each>
           <mods:edition>[Electronic edition]</mods:edition>
         
           <xsl:for-each select="./p:datafield[@tag='011B']">   <!-- 1109 -->
              <xsl:choose>
                <xsl:when test="./p:subfield[@code='b']">
                  <mods:dateCaptured encoding="iso8601" point="start" keyDate="yes"><xsl:value-of select="./p:subfield[@code='a']" /></mods:dateCaptured>
                  <mods:dateCaptured encoding="iso8601" point="end"><xsl:value-of select="./p:subfield[@code='b']" /></mods:dateCaptured>
                </xsl:when>
                <xsl:otherwise>
                  <mods:dateCaptured encoding="iso8601" keyDate="yes"><xsl:value-of select="./p:subfield[@code='a']" /></mods:dateCaptured>
              </xsl:otherwise>
             </xsl:choose> 
           </xsl:for-each>
         </mods:originInfo>

        
        <xsl:for-each select="./p:datafield[@tag='017C' and contains(./p:subfield[@code='u'], '//purl.uni-rostock.de')][1]">
          <mods:location>
                <mods:physicalLocation type="online" authorityURI="http://d-nb.info/gnd/" valueURI="http://d-nb.info/gnd/25968-8">Universitätsbibliothek Rostock</mods:physicalLocation>
                <mods:url usage="primary" access="object in context"><xsl:value-of select="./p:subfield[@code='u']" /></mods:url>
         </mods:location>              
        </xsl:for-each>
        
         <xsl:for-each select="./p:datafield[@tag='044S']"> <!-- 5570 Gattungsbegriffe AAD -->
          <mods:genre type="aadgenre"><xsl:value-of select="./p:subfield[@code='a']"/></mods:genre>
          <xsl:call-template name="COMMON_UBR_Class_AADGenres" />
         </xsl:for-each>     
         
         <xsl:call-template name="COMMON_UBR_Class_Collection" />
         <xsl:call-template name="COMMON_UBR_Class_Provider" />
         <xsl:call-template name="COMMON_UBR_Class_Doctype" />
         <xsl:call-template name="COMMON_CLASS" />

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