<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xalan="http://xml.apache.org/xalan" xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:p="info:srw/schema/5/picaXML-v1.0" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="p xalan fn">
  <xsl:import href="cp:ubr/ubr_pica2mods_common.xsl" />

  <xsl:variable name="XSL_VERSION_RAK" select="concat('ubr_pica2mods_RAK.xsl from ',$XSL_VERSION_PICA2MODS)" />
  <xsl:template match="/p:record" mode="RAK">
  	<xsl:variable name="ppnA" select="./p:datafield[@tag='039D'][./p:subfield[@code='C']='GBV']/p:subfield[@code='6']/text()" />
	<xsl:variable name="pica0500_2" select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
  <xsl:if test="$ppnA">
    	<mods:note type="PPN-A"><xsl:value-of select="$ppnA" /></mods:note>
    </xsl:if> 
          <xsl:for-each select="./p:datafield[@tag='017C']"> <!-- 4950 (kein eigenes Feld) -->
          <xsl:if test="contains(./p:subfield[@code='u'], '//purl.uni-rostock.de')">
            <mods:identifier type="purl"><xsl:value-of select="./p:subfield[@code='u']" /></mods:identifier>
          </xsl:if>          
      </xsl:for-each>
              
      <xsl:for-each select="./p:datafield[@tag='028A' or @tag='028B']"> <!-- 300x -->
        <xsl:call-template name="RAK_PersonalName">
          <xsl:with-param name="marcrelatorCode">aut</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
      
      <xsl:for-each select="./p:datafield[@tag='028C' or @tag='028D' or @tag='028E'or @tag='028F'or @tag='028G'or @tag='028H'or @tag='028L'or @tag='028M']"> <!-- 300x -->
        <xsl:call-template name="RAK_PersonalName" />
      </xsl:for-each>
      
      <xsl:for-each select="./p:datafield[@tag='029A' or @tag='029F' or @tag='029G' or @tag='029E']"> <!-- 310X -->
        <xsl:call-template name="RAK_CorporateName">
          
        </xsl:call-template>
      </xsl:for-each>
      
      
      <xsl:choose>
         <xsl:when test="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)='f' or substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)='F' ">
           <xsl:for-each select="./p:datafield[@tag='036C']"><!-- 4150 -->
              <xsl:call-template name="RAK_Title" />
           </xsl:for-each>  
        </xsl:when>
        <xsl:when test="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)='v' and ./p:datafield[@tag='027D']">
           <xsl:for-each select="./p:datafield[@tag='027D']"><!-- 3290 -->
              <xsl:call-template name="RAK_Title" />
           </xsl:for-each>  
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="./p:datafield[@tag='021A']"> <!--  4000 -->
              <xsl:call-template name="RAK_Title" />
           </xsl:for-each>  
        </xsl:otherwise>
      </xsl:choose>
      
      <xsl:for-each select="./p:datafield[@tag='036D']"> <!-- 4160  übergeordnetes Werk-->
        <xsl:call-template name="RAK_HostOrSeries">
           <xsl:with-param name="type">host</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>

      <!--TODO: Unterscheidung nach 0500 2. Pos: wenn 'v' dann type->host, sonst type->series -->
      <xsl:for-each select="./p:datafield[@tag='036F']"> <!-- 4180  Schriftenreihe, Zeitschrift-->
		<xsl:choose>
			<xsl:when test="$pica0500_2='v'">
				<xsl:call-template name="RAK_HostOrSeries">
		           <xsl:with-param name="type">host</xsl:with-param>
		        </xsl:call-template>
		    </xsl:when>
		    <xsl:when test="$pica0500_2='b'">
				<xsl:call-template name="RAK_HostOrSeries">
		           <xsl:with-param name="type">series</xsl:with-param>
		        </xsl:call-template>
		    </xsl:when>		    
	    </xsl:choose>
      </xsl:for-each>
      
      <xsl:for-each select="./p:datafield[@tag='039P']"> <!-- 4261  RezensiertesWerk-->
          <xsl:call-template name="RAK_Review" />
      </xsl:for-each>


         <xsl:for-each select="./p:datafield[@tag='044S']"> <!-- 5570 Gattungsbegriffe AAD -->
          <mods:genre type="aadgenre"><xsl:value-of select="./p:subfield[@code='a']"/></mods:genre>
          <xsl:call-template name="COMMON_UBR_Class_AADGenres" />
         </xsl:for-each>     
         
        <xsl:for-each select="./p:datafield[@tag='017H']">
          <mods:note>
            <xsl:attribute name="xlink:href"><xsl:value-of select="./p:subfield[@code='u']" /></xsl:attribute>
            <xsl:value-of select="./p:subfield[@code='y']" />
          </mods:note>
        </xsl:for-each>
    
        <xsl:for-each select="./p:datafield[@tag='007S']"><!-- 2277 -->
        <xsl:if test="not(starts-with(./p:subfield[@code='0'], 'VD 16')) and not(starts-with(./p:subfield[@code='0'], 'VD17')) and not(starts-with(./p:subfield[@code='0'], 'VD18')) and not(starts-with(./p:subfield[@code='0'], 'RISM')) and not(starts-with(./p:subfield[@code='0'], 'Kalliope')) and not(./p:subfield[@code='S']='e')">
          <mods:note type="bibliographic_reference"><xsl:value-of select="./p:subfield[@code='0']" /></mods:note>
        </xsl:if>
      </xsl:for-each>
      
      <xsl:for-each select="./p:datafield[@tag='037G']">
        <mods:note type="reproduction">
          <xsl:value-of select="./p:subfield[@code='a']" />
        </mods:note>
      </xsl:for-each>
      
      <xsl:for-each select="./p:datafield[@tag='037A' or @tag='037B' or @tag='046L' or @tag='046F' or @tag='046G' or @tag='046H' or @tag='046I'  or @tag='046P']"><!-- 4201, 4202, 4221, 4215, 4216, 4217, 4218, 4225 -->
          <mods:note type="other"><xsl:value-of select="./p:subfield[@code='a']" /></mods:note>
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

      
	<!-- 
      <mods:extension displayLabel="picaxml">
        <xsl:copy-of select="." />
      </mods:extension>
	-->
  </xsl:template>
  <xsl:template name="RAK_HostOrSeries">
    <xsl:param name="type" />
          <mods:relatedItem>
          <!--  ToDo teilweise redundant mit title template -->
           <xsl:attribute name="type"><xsl:value-of select="$type" /></xsl:attribute>
           <mods:titleInfo>
           <xsl:if test="./p:subfield[@code='a']">
              <xsl:variable name="mainTitle" select="./p:subfield[@code='a']" />
               <xsl:choose>
          <xsl:when test="contains($mainTitle, '@')">
            <xsl:variable name="nonSort" select="normalize-space(substring-before($mainTitle, '@'))" />
            <xsl:choose>
              <xsl:when test="string-length(nonSort) &lt; 9">
                <mods:nonSort><xsl:value-of select="$nonSort" /></mods:nonSort>
                <mods:title>
                  <xsl:value-of select="substring-after($mainTitle, '@')"  />
                </mods:title>
              </xsl:when>
              <xsl:otherwise>
                <mods:title><xsl:value-of select="$mainTitle" /></mods:title>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <mods:title><xsl:value-of select="$mainTitle"/></mods:title>
          </xsl:otherwise>
        </xsl:choose>
           </xsl:if>
          </mods:titleInfo>
           <xsl:if test="./p:subfield[@code='9']">
           <xsl:if test="not($type = 'series')">
              <mods:recordInfo><mods:recordIdentifier source="DE-28">rosdok/ppn<xsl:value-of select="./p:subfield[@code='9']" /></mods:recordIdentifier></mods:recordInfo>
              <mods:identifier type="purl">http://purl.uni-rostock.de/rosdok/ppn<xsl:value-of select="./p:subfield[@code='9']" /></mods:identifier>
            </xsl:if>
            <xsl:if test="$type = 'series'">
              <mods:identifier type="gvk:ppn"><xsl:value-of select="./p:subfield[@code='9']" /></mods:identifier>
            </xsl:if>
          </xsl:if>
           
            <mods:part>
              <!-- order attributefrom subfield $X - without check
              <xsl:if test="./p:subfield[@code='X']">
                <xsl:attribute name="order">
                  <xsl:choose>
                    <xsl:when test="contains(./p:subfield[@code='X'], ',')">
                        <xsl:value-of select="substring-before(substring-before(./p:subfield[@code='X'], '.'), ',')" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before(./p:subfield[@code='X'], '.')" />
                    </xsl:otherwise>
                 </xsl:choose>   
                 </xsl:attribute>
              </xsl:if>
 			  -->

				<!-- set order attribute only if value of subfield $X is a number --> 
				<xsl:if test="./p:subfield[@code='X']">
                  <xsl:choose>
                    <xsl:when test="contains(./p:subfield[@code='X'], ',')">
                	    <xsl:if test="number(substring-before(substring-before(./p:subfield[@code='X'], '.'), ','))">
    						<xsl:attribute name="order">		
                        		<xsl:value-of select="substring-before(substring-before(./p:subfield[@code='X'], '.'), ',')" />
							</xsl:attribute>
						</xsl:if>			
                    </xsl:when>
                    <xsl:otherwise>
                    	<xsl:if test="number(substring-before(./p:subfield[@code='X'], '.'))">
                    		<xsl:attribute name="order">
                        		<xsl:value-of select="substring-before(./p:subfield[@code='X'], '.')" />
                        	</xsl:attribute>
                        </xsl:if>
                    </xsl:otherwise>
                 </xsl:choose>   
              </xsl:if>
              
              <!-- ToDo:  type attribute: issue, volume, chapter, .... --> 
              <xsl:if test="./p:subfield[@code='l']">
                <mods:detail type="volume"><mods:number><xsl:value-of select="./p:subfield[@code='l']" /></mods:number></mods:detail>
              </xsl:if>
              <xsl:if test="./p:subfield[@code='X' or @code='x']">
                  <mods:text type="sortstring"><xsl:value-of select="./p:subfield[@code='X' or @code='x']" /></mods:text>
              </xsl:if>
            </mods:part>
          
        </mods:relatedItem>
  </xsl:template>
    
  <xsl:template name="RAK_Review">
      <mods:relatedItem type="reviewOf">
           <mods:titleInfo>
           <xsl:if test="./p:subfield[@code='a']">
              <xsl:variable name="mainTitle" select="./p:subfield[@code='a']" />
               <xsl:choose>
          <xsl:when test="contains($mainTitle, '@')">
            <xsl:variable name="nonSort" select="normalize-space(substring-before($mainTitle, '@'))" />
            <xsl:choose>
              <xsl:when test="string-length(nonSort) &lt; 9">
                <mods:nonSort><xsl:value-of select="$nonSort" /></mods:nonSort>
                <mods:title>
                  <xsl:value-of select="substring-after($mainTitle, '@')"  />
                </mods:title>
              </xsl:when>
              <xsl:otherwise>
                <mods:title><xsl:value-of select="$mainTitle" /></mods:title>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <mods:title><xsl:value-of select="$mainTitle"/></mods:title>
          </xsl:otherwise>
        </xsl:choose>
           </xsl:if>
          </mods:titleInfo>
          <mods:identifier type="PPN"><xsl:value-of select="./p:subfield[@code='9']"/></mods:identifier>
    
  </mods:relatedItem>
  </xsl:template>
  
  <xsl:template name="RAK_Title">
    <mods:titleInfo usage="primary">
      <xsl:if test="./p:subfield[@code='a']">
        <xsl:variable name="mainTitle" select="./p:subfield[@code='a']" />
        <xsl:choose>
          <xsl:when test="contains($mainTitle, '@')">
            <xsl:variable name="nonSort" select="normalize-space(substring-before($mainTitle, '@'))" />
            <xsl:choose>
              <xsl:when test="string-length(nonSort) &lt; 9">
                <mods:nonSort><xsl:value-of select="$nonSort" /></mods:nonSort>
                <mods:title>
                  <xsl:value-of select="substring-after($mainTitle, '@')"  />
                </mods:title>
              </xsl:when>
              <xsl:otherwise>
                <mods:title><xsl:value-of select="$mainTitle" /></mods:title>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <mods:title><xsl:value-of select="$mainTitle"/></mods:title>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="./p:subfield[@code='d']">
        <mods:subTitle><xsl:value-of select="./p:subfield[@code='d']" /></mods:subTitle>
      </xsl:if>
      
      <!--  nur in fingierten Titel 036C / 4150 -->
      <xsl:if test="./p:subfield[@code='y']">
        <mods:subTitle><xsl:value-of select="./p:subfield[@code='y']" /></mods:subTitle>
      </xsl:if>
      <xsl:if test="./p:subfield[@code='l']">
        <mods:partNumber><xsl:value-of select="./p:subfield[@code='l']" /></mods:partNumber>
      </xsl:if>
      <xsl:if test="./@tag='036C' and not(./p:subfield[@code='l']) and ./../p:datafield[@tag='036D']/p:subfield[@code='l']">
        <mods:partNumber>
          <xsl:value-of select="./../p:datafield[@tag='036D']/p:subfield[@code='l']" />
        </mods:partNumber>
      </xsl:if>
      
      <xsl:if test="@tag='027D'">
        <mods:partNumber><xsl:value-of select="./../p:datafield[@tag='036F']/p:subfield[@code='l']" /></mods:partNumber>
      </xsl:if>

       <xsl:if test="@tag='036C' and ./../p:datafield[@tag='021A']">
       		<xsl:if test="./../p:datafield[@tag='021A']/p:subfield[@code='a'] != '@'">
            	<mods:partName><xsl:value-of select="translate(./../p:datafield[@tag='021A']/p:subfield[@code='a'], '@', '')" /></mods:partName>
            </xsl:if>
       </xsl:if>
    </mods:titleInfo>

    <xsl:for-each select="./../p:datafield[@tag='021A' or @tag='027D' or @tag='036C']/p:subfield[@code='h']">
      <mods:note type="creator_info">
        <xsl:value-of select="./text()" />
      </mods:note>
    </xsl:for-each>
  </xsl:template>

  
</xsl:stylesheet> 