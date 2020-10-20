<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="p xalan fn">

  <xsl:template name="COMMON_Title">
    <mods:titleInfo>
      <xsl:attribute name="usage">primary</xsl:attribute>
      <xsl:if test="./p:subfield[@code='a']">
        <xsl:variable name="mainTitle" select="./p:subfield[@code='a']" />
        <xsl:choose>
          <xsl:when test="contains($mainTitle, '@')">
            <xsl:variable name="nonSort" select="normalize-space(substring-before($mainTitle, '@'))" />
            <xsl:choose>
              <xsl:when test="string-length(nonSort) &lt; 9">
                <mods:nonSort>
                  <xsl:value-of select="$nonSort" />
                </mods:nonSort>
                <mods:title>
                  <xsl:value-of select="substring-after($mainTitle, '@')" />
                </mods:title>
              </xsl:when>
              <xsl:otherwise>
                <mods:title>
                  <xsl:value-of select="$mainTitle" />
                </mods:title>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <mods:title>
              <xsl:value-of select="$mainTitle" />
            </mods:title>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <xsl:if test="./p:subfield[@code='d']">
        <mods:subTitle>
          <xsl:value-of select="./p:subfield[@code='d']" />
        </mods:subTitle>
      </xsl:if>

      <!-- nur in fingierten Titel 036C / 4150 -->
      <xsl:if test="./p:subfield[@code='y']">
        <mods:subTitle>
          <xsl:value-of select="./p:subfield[@code='y']" />
        </mods:subTitle>
      </xsl:if>

      <xsl:if test="./p:subfield[@code='l']">
        <mods:partNumber>
          <xsl:value-of select="./p:subfield[@code='l']" />
        </mods:partNumber>
      </xsl:if>
      <xsl:if test="./@tag='036C' and not(./p:subfield[@code='l']) and ./../p:datafield[@tag='036D']/p:subfield[@code='l']">
        <mods:partNumber>
          <xsl:value-of select="./../p:datafield[@tag='036D']/p:subfield[@code='l']" />
        </mods:partNumber>
      </xsl:if>

      <xsl:if test="(@tag='036C' or @tag='036F') and ./../p:datafield[@tag='021A']">
       <xsl:variable name="out">
        <xsl:value-of select="translate(./../p:datafield[@tag='021A']/p:subfield[@code='a'], '@', '')" />
            <xsl:if test="./../p:datafield[@tag='021A']/p:subfield[@code='d']">
            : <xsl:value-of select="./../p:datafield[@tag='021A']/p:subfield[@code='d']" />
            </xsl:if>
       </xsl:variable>
       <mods:partName>
          <xsl:value-of select="normalize-space($out)"></xsl:value-of>         
       </mods:partName>
      </xsl:if>
    </mods:titleInfo>

    <xsl:if test="./../p:datafield[@tag='021A']/p:subfield[@code='h']">
      <mods:note type="statement of responsibility">
        <xsl:value-of select="./../p:datafield[@tag='021A']/p:subfield[@code='h']" />
      </mods:note>
    </xsl:if>
  </xsl:template>
  
   <xsl:template name="COMMON_Alt_Uniform_Title">
      <!-- 3260/027A$a abweichender Titel,
         4212/046C abweichender Titel,
         4213/046D früherere Hauptitel
         4002/021F Paralleltitel,
         4000/021A$f Paralleltitel (RAK), 
         
         3210/022A Werktitel, 
         3232/026C Zeitschriftenkurztitel -->
  <xsl:for-each select="./p:datafield[@tag='027A' or @tag='021F' or @tag='046C' or @tag='046D']/p:subfield[@code='a'] | ./p:datafield[@tag='021A']/p:subfield[@code='f'] ">
    <mods:titleInfo type="alternative">
      <mods:title>
        <xsl:if test="./../p:subfield[@code='i']"><xsl:value-of select="./../p:subfield[@code='i']" />: </xsl:if>
      <xsl:value-of select="translate(., '@', '')" /></mods:title>
    </mods:titleInfo>
  </xsl:for-each>
  <xsl:for-each select="./p:datafield[@tag='022A']">
    <mods:titleInfo type="uniform">
      <mods:title><xsl:value-of select="translate(./p:subfield[@code='a'], '@', '')" /></mods:title>
    </mods:titleInfo>
  </xsl:for-each>
  <xsl:for-each select="./p:datafield[@tag='026C']">
    <mods:titleInfo type="abbreviated">
      <mods:title><xsl:value-of select="translate(./p:subfield[@code='a'], '@', '')" /></mods:title>
    </mods:titleInfo>
  </xsl:for-each>
</xsl:template>

  <xsl:template name="COMMON_HostOrSeries">
    <mods:relatedItem>
      <xsl:if test="./p:subfield[@code='9']">
          <xsl:variable name="query" select="concat('unapi:k10plus:ppn:', ./p:subfield[@code='9'])" />
          <xsl:variable name="od" select="document($query)"/>
          <xsl:choose>
            <xsl:when test="$od/p:record/p:datafield[@tag='017C']/p:subfield[@code='u'][starts-with(.,'http://purl.uni-rostock.de/')][1]">
              <xsl:for-each select="$od/p:record/p:datafield[@tag='017C']/p:subfield[@code='u'][starts-with(.,'http://purl.uni-rostock.de/')][1]">
              <xsl:attribute name="type">host</xsl:attribute> 
         
              <mods:recordInfo>
              <mods:recordIdentifier source="DE-28">
                <xsl:value-of select="substring(.,28,100) " />
              </mods:recordIdentifier>
            </mods:recordInfo>
              <mods:identifier type="purl">
                <xsl:value-of select="." />
              </mods:identifier>
          </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="type">series</xsl:attribute> 
            </xsl:otherwise>
          </xsl:choose>
          <mods:identifier type="PPN">
            <xsl:value-of select="$od/p:record/p:datafield[@tag='003@']/p:subfield[@code='0']" />
         </mods:identifier>      
          <xsl:if test="$od/p:record/p:datafield[@tag='006Z']/p:subfield[@code='0']">
            <mods:identifier type="zdb">
              <xsl:value-of select="$od/p:record/p:datafield[@tag='006Z']/p:subfield[@code='0']" />
            </mods:identifier>
          </xsl:if>
     </xsl:if>
      <xsl:if test="not(./p:subfield[@code='9'])">
        <xsl:attribute name="type">series</xsl:attribute>
      </xsl:if>
     
      <!-- ToDo teilweise redundant mit title template -->
      <mods:titleInfo>
        <xsl:if test="./p:subfield[@code='a']">
          <xsl:variable name="mainTitle" select="./p:subfield[@code='a']" />
          <xsl:choose>
            <xsl:when test="contains($mainTitle, '@')">
              <xsl:variable name="nonSort" select="normalize-space(substring-before($mainTitle, '@'))" />
              <xsl:choose>
                <xsl:when test="string-length(nonSort) &lt; 9">
                  <mods:nonSort>
                    <xsl:value-of select="$nonSort" />
                  </mods:nonSort>
                  <mods:title>
                    <xsl:value-of select="substring-after($mainTitle, '@')" />
                  </mods:title>
                </xsl:when>
                <xsl:otherwise>
                  <mods:title>
                    <xsl:value-of select="$mainTitle" />
                  </mods:title>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <mods:title>
                <xsl:value-of select="$mainTitle" />
              </mods:title>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </mods:titleInfo>

      <mods:part>
        <!-- set order attribute only if value of subfield $X is a number -->
        <xsl:if test="./p:subfield[@code='X']">
          <xsl:choose>
            <!-- sort string contains 2 commas -->
            <xsl:when test="string-length(./p:subfield[@code='X']) = string-length(translate(./p:subfield[@code='X'], ',','')) + 2">
                <xsl:if test="number(translate(./p:subfield[@code='X'], ',',''))">
                  <xsl:attribute name="order">    
                    <xsl:value-of select="translate(./p:subfield[@code='X'], ',','')" />
                  </xsl:attribute>
                </xsl:if>
            </xsl:when>
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

        <!-- ToDo: type attribute: issue, volume, chapter, .... -->
        <xsl:if test="./p:subfield[@code='l']">
          <mods:detail type="volume">
            <mods:number>
              <xsl:value-of select="./p:subfield[@code='l']" />
            </mods:number>
          </mods:detail>
        </xsl:if>
        <xsl:if test="@tag='036D' and ./p:subfield[@code='X']">
          <mods:text type="sortstring">
            <xsl:value-of select="./p:subfield[@code='X']" />
          </mods:text>
        </xsl:if>
        <xsl:if test="@tag='036F' and ./p:subfield[@code='X']">
          <mods:text type="sortstring">
            <xsl:value-of select="./p:subfield[@code='X']" />
          </mods:text>
        </xsl:if>
      </mods:part>
    </mods:relatedItem>
  </xsl:template>
  
  <xsl:template name="COMMON_AppearsIn">
    <mods:relatedItem>
      <xsl:attribute name="type">host</xsl:attribute>
      <xsl:attribute name="displayLabel">appears_in</xsl:attribute>
      <xsl:if test="./p:subfield[@code='l']">
    <mods:name>
      <mods:displayForm>
        <xsl:value-of select="./p:subfield[@code='l']" />
      </mods:displayForm>
    </mods:name>
    </xsl:if>
    <xsl:if test="./p:subfield[@code='t']">
    <mods:titleInfo>
        <mods:title>
        <xsl:value-of select="./p:subfield[@code='t']" />
            </mods:title>
    </mods:titleInfo>
    </xsl:if>
    <xsl:if test="./p:subfield[@code='p']">
    <mods:part>
      <mods:text>
        <xsl:value-of select="./p:subfield[@code='p']" />
      </mods:text>
    </mods:part>
    </xsl:if>
    <xsl:if test="./p:subfield[@code='C' and text()='DOI']">
        <mods:identifier type="doi">
          <xsl:value-of select="./p:subfield[@code='C' and text()='DOI']/following-sibling::p:subfield[@code='6'][1]"></xsl:value-of>
        </mods:identifier>
      </xsl:if>
    <xsl:if test="./p:subfield[@code='C' and text()='ISBN']">
        <mods:identifier type="isbn">
          <xsl:value-of select="./p:subfield[@code='C' and text()='ISBN']/following-sibling::p:subfield[@code='6'][1]"></xsl:value-of>
        </mods:identifier>
      </xsl:if>
    <xsl:if test="./p:subfield[@code='C' and text()='ISSN']">
        <mods:identifier type="issn">
          <xsl:value-of select="./p:subfield[@code='C' and text()='ISSN']/following-sibling::p:subfield[@code='6'][1]"></xsl:value-of>
        </mods:identifier>
      </xsl:if>
    <xsl:if test="./p:subfield[@code='C' and text()='ZDB']">
        <mods:identifier type="zdb">
          <xsl:value-of select="./p:subfield[@code='C' and text()='ZDB']/following-sibling::p:subfield[@code='6'][1]"></xsl:value-of>
        </mods:identifier>
      </xsl:if>
    </mods:relatedItem>
  </xsl:template>

  <xsl:template name="COMMON_Review">
    <mods:relatedItem type="reviewOf">
      <mods:titleInfo>
        <xsl:if test="./p:subfield[@code='a']">
          <xsl:variable name="mainTitle" select="./p:subfield[@code='a']" />
          <xsl:choose>
            <xsl:when test="contains($mainTitle, '@')">
              <xsl:variable name="nonSort" select="normalize-space(substring-before($mainTitle, '@'))" />
              <xsl:choose>
                <xsl:when test="string-length(nonSort) &lt; 9">
                  <mods:nonSort>
                    <xsl:value-of select="$nonSort" />
                  </mods:nonSort>
                  <mods:title>
                    <xsl:value-of select="substring-after($mainTitle, '@')" />
                  </mods:title>
                </xsl:when>
                <xsl:otherwise>
                  <mods:title>
                    <xsl:value-of select="$mainTitle" />
                  </mods:title>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <mods:title>
                <xsl:value-of select="$mainTitle" />
              </mods:title>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </mods:titleInfo>
      <mods:identifier type="PPN">
        <xsl:value-of select="./p:subfield[@code='9']" />
      </mods:identifier>
    </mods:relatedItem>
  </xsl:template>

  <xsl:template name="COMMON_PersonalName">
    <!-- Lb: RDA, jetzt marcrelatorcode gemäß $4 bzw. ausgeschrieben $B -->
    <xsl:for-each select="./p:datafield[starts-with(@tag, '028') or @tag='033J']">
      <xsl:choose>
        <xsl:when test="./p:subfield[@code='9']">
          <xsl:variable name="query" select="concat('unapi:k10plus:ppn:', ./p:subfield[@code='9'])" />
          <xsl:variable name="tp" select="document($query)"/>
          <xsl:if test="starts-with($tp/p:record/p:datafield[@tag='002@']/p:subfield[@code='0'], 'Tp')">
          <mods:name type="personal">
           <mods:nameIdentifier type="gnd"><xsl:value-of select="$tp/p:record/p:datafield[@tag='007K' and ./p:subfield[@code='a']='gnd']/p:subfield[@code='0']" /></mods:nameIdentifier>
           <xsl:if test="$tp/p:record/p:datafield[@tag='006X' and ./p:subfield[@code='S']='orcid']"> 
            <mods:nameIdentifier type="orcid"><xsl:value-of select="$tp/p:record/p:datafield[@tag='006X' and ./p:subfield[@code='S']='orcid']/p:subfield[@code='0']" /></mods:nameIdentifier>
           </xsl:if>
           
           <xsl:if test="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='d']">
              <mods:namePart type="given"><xsl:value-of select="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='d']" /></mods:namePart>
           </xsl:if>
           <xsl:if test="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='a']">
              <mods:namePart type="family"><xsl:value-of select="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='a']" /></mods:namePart>
           </xsl:if>
           <xsl:if test="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='P']">
              <mods:namePart type="family"><xsl:value-of select="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='P']" /></mods:namePart>
           </xsl:if>
           <xsl:if test="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='c']">
              <mods:namePart type="termsOfAddress"><xsl:value-of select="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='c']" /></mods:namePart>
           </xsl:if>
           <xsl:if test="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='n']">
              <mods:namePart type="termsOfAddress"><xsl:value-of select="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='n']" /></mods:namePart>
           </xsl:if>
           <xsl:if test="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='l']">
              <mods:namePart type="termsOfAddress"><xsl:value-of select="$tp/p:record/p:datafield[@tag='028A']/p:subfield[@code='l']" /></mods:namePart>
           </xsl:if>
           <xsl:for-each select="$tp/p:record/p:datafield[@tag='060R' and ./p:subfield[@code='4']='datl']">
               <xsl:if test="./p:subfield[@code='a']">
                <xsl:variable name="out_date">
                  <xsl:value-of select="./p:subfield[@code='a']" />
                  -
                   <xsl:value-of select="./p:subfield[@code='b']" />
                 </xsl:variable>
                 <mods:namePart type="date"><xsl:value-of select="normalize-space($out_date)"></xsl:value-of></mods:namePart>
              </xsl:if>
              <xsl:if test="./p:subfield[@code='d']">
                 <mods:namePart type="date"><xsl:value-of select="./p:subfield[@code='d']"></xsl:value-of></mods:namePart>
              </xsl:if>
          </xsl:for-each>
          <xsl:call-template name="COMMON_PersonalName_ROLES">
            <xsl:with-param name="datafield" select="." />
          </xsl:call-template>
          </mods:name>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
        <mods:name type="personal">
        <xsl:if test="./p:subfield[@code='d']">
          <mods:namePart type="given">
            <xsl:value-of select="./p:subfield[@code='d']" />
          </mods:namePart>
        </xsl:if>
        <xsl:if test="./p:subfield[@code='a']">
          <mods:namePart type="family">
            <xsl:value-of select="./p:subfield[@code='a']" />
          </mods:namePart>
        </xsl:if>
        <xsl:if test="./p:subfield[@code='c']">
          <mods:namePart type="termsOfAddress">
          	<xsl:value-of select="./p:subfield[@code='c']" />
          </mods:namePart>
        </xsl:if>
        
        <xsl:if test="./p:subfield[@code='P']">
          <mods:namePart>
            <xsl:value-of select="./p:subfield[@code='P']" />
          </mods:namePart>
        </xsl:if>
        <xsl:if test="./p:subfield[@code='n']">
          <mods:namePart type="termsOfAddress">
            <xsl:value-of select="./p:subfield[@code='n']" />
          </mods:namePart>
        </xsl:if>
        <xsl:if test="./p:subfield[@code='l']">
          <mods:namePart type="termsOfAddress">
            <xsl:value-of select="./p:subfield[@code='l']" />
          </mods:namePart>
        </xsl:if>
        <xsl:call-template name="COMMON_PersonalName_ROLES">
          <xsl:with-param name="datafield" select="." />
        </xsl:call-template>
        </mods:name>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="COMMON_PersonalName_ROLES">
      <xsl:param name="datafield"></xsl:param>
      <xsl:choose>
        <xsl:when test="$datafield/p:subfield[@code='4']">
          <xsl:for-each select="$datafield/p:subfield[@code='4']">
            <mods:role>
              <xsl:if test="preceding-sibling::p:subfield[@code='B']">
                <mods:roleTerm type="text" authority="GBV">
                  <xsl:value-of select="preceding-sibling::p:subfield[@code='B'][last()]" />
                </mods:roleTerm>
              </xsl:if>
              <mods:roleTerm type="code" authority="marcrelator">
                <xsl:value-of select="." />
              </mods:roleTerm>
            </mods:role>
          </xsl:for-each>
        </xsl:when>
      
        <!-- Alt: Heuristiken für RAK-Aufnahmen -->
        <xsl:when test="$datafield/p:subfield[@code='B']">
           <mods:role>
             <mods:roleTerm type="code" authority="marcrelator">
              <xsl:choose> 
                <!-- RAK WB §185, 2 -->
                <xsl:when test="$datafield/p:subfield[@code='B']='Bearb.'">ctb</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='Begr.'">org</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='Hrsg.'">edt</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='Ill.'">ill</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='Komp.'">cmp</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='Mitarb.'">ctb</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='Red.'">red</xsl:when>
                <!-- GBV Katalogisierungsrichtlinie -->
                <xsl:when test="$datafield/p:subfield[@code='B']='Adressat'">rcp</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='angebl. Hrsg.'">edt</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='mutmaßl. Hrsg.'">edt</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='Komm.'">ann</xsl:when><!-- Kommentator = annotator -->
                <xsl:when test="$datafield/p:subfield[@code='B']='Stecher'">egr</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='angebl. Übers.'">trl</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='mutmaßl. Übers.'">trl</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='angebl. Verf.'">dub</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='mutmaßl. Verf.'">dub</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='Verstorb.'">oth</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='Zeichner'">drm</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='Präses'">pra</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='Resp.'">rsp</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='Widmungsempfänger'">dto</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='Zensor'">cns</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='Beiträger'">ctb</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='Beiträger k.'">ctb</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='Beiträger m.'">ctb</xsl:when>
                <xsl:when test="$datafield/p:subfield[@code='B']='Interpr.'">prf</xsl:when> <!-- Interpret = Performer-->               
                <xsl:otherwise>oth</xsl:otherwise>
                </xsl:choose>
              </mods:roleTerm>
              <mods:roleTerm type="text" authority="GBV"><xsl:value-of select="$datafield/p:subfield[@code='B']" /></mods:roleTerm>
           </mods:role>
        </xsl:when>
        <xsl:when test="@tag='028A' or @tag='028B'">
            <mods:role>
              <mods:roleTerm type="code" authority="marcrelator">aut</mods:roleTerm>
              <mods:roleTerm type="text" authority="GBV">Verfasser</mods:roleTerm>
            </mods:role>
        </xsl:when>
        <xsl:when test="@tag='033J'">
          <mods:role>
            <mods:roleTerm type="text" authority="GBV">DruckerIn</mods:roleTerm>
            <mods:roleTerm type="code" authority="marcrelator">prt</mods:roleTerm>
          </mods:role>
        </xsl:when>
        <xsl:otherwise>
          <mods:role><mods:roleTerm type="code" authority="marcrelator">oth</mods:roleTerm></mods:role>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  
  <xsl:template name="COMMON_CorporateName">
    <!-- Lb: RDA, jetzt marcrelatorcode gemäß $4 bzw. ausgeschrieben $B -->
    <!-- zusätzlich geprüft 033J =  4043 Druckernormadaten (alt) -->
    <xsl:for-each select="./p:datafield[starts-with(@tag, '029') or @tag='033J']">
        <xsl:choose>
        <xsl:when test="./p:subfield[@code='9']">
          <xsl:variable name="query" select="concat('unapi:k10plus:ppn:', ./p:subfield[@code='9'])" />
          <xsl:variable name="tb" select="document($query)"/>
          <xsl:if test="starts-with($tb/p:record/p:datafield[@tag='002@']/p:subfield[@code='0'], 'Tb')">
          <mods:name type="corporate">
          <mods:nameIdentifier type="gnd"><xsl:value-of select="$tb/p:record/p:datafield[@tag='007K' and ./p:subfield[@code='a']='gnd']/p:subfield[@code='0']" /></mods:nameIdentifier>
           <xsl:if test="$tb/p:record/p:datafield[@tag='029A']/p:subfield[@code='a']">
              <mods:namePart><xsl:value-of select="$tb/p:record/p:datafield[@tag='029A']/p:subfield[@code='a']" /></mods:namePart>
           </xsl:if>
           <xsl:if test="$tb/p:record/p:datafield[@tag='029A']/p:subfield[@code='b']">
              <mods:namePart><xsl:value-of select="$tb/p:record/p:datafield[@tag='029A']/p:subfield[@code='b']" /></mods:namePart>
           </xsl:if>
           <xsl:if test="$tb/p:record/p:datafield[@tag='029A']/p:subfield[@code='g']">
              <mods:namePart><xsl:value-of select="$tb/p:record/p:datafield[@tag='029A']/p:subfield[@code='g']" /></mods:namePart>
           </xsl:if>
           <xsl:if test="$tb/p:record/p:datafield[@tag='065A']/p:subfield[@code='a']">
              <mods:namePart><xsl:value-of select="$tb/p:record/p:datafield[@tag='065A']/p:subfield[@code='a']" /></mods:namePart>
           </xsl:if>
           <xsl:if test="$tb/p:record/p:datafield[@tag='065A']/p:subfield[@code='g']">
              <mods:namePart><xsl:value-of select="$tb/p:record/p:datafield[@tag='065A']/p:subfield[@code='g']" /></mods:namePart>
           </xsl:if>
           
            <xsl:for-each select="$tb/p:record/p:datafield[@tag='060R' and (./p:subfield[@code='4']='datb' or ./p:subfield[@code='4']='datv')]">
               <xsl:if test="./p:subfield[@code='a']">
                <xsl:variable name="out_date">
                  <xsl:value-of select="./p:subfield[@code='a']" />
                  -
                  <xsl:value-of select="./p:subfield[@code='b']" />
                 </xsl:variable>
                 <mods:namePart type="date"><xsl:value-of select="normalize-space($out_date)"/></mods:namePart>
              </xsl:if>
              <xsl:if test="./p:subfield[@code='d']">
                 <mods:namePart type="date"><xsl:value-of select="./p:subfield[@code='d']" /></mods:namePart>
              </xsl:if>
          </xsl:for-each>
          <xsl:call-template name="COMMON_CorporateName_ROLES">
            <xsl:with-param name="datafield" select="." />
          </xsl:call-template>
          </mods:name>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
        <mods:name type="corporate">
        <xsl:if test="./p:subfield[@code='a']">
          <mods:namePart>
            <xsl:value-of select="./p:subfield[@code='a']" />
          </mods:namePart>
        </xsl:if>
        <xsl:if test="./p:subfield[@code='b']">
          <mods:namePart>
            <xsl:value-of select="./p:subfield[@code='b']" />
          </mods:namePart>
        </xsl:if>
        <xsl:if test="./p:subfield[@code='d']">
          <mods:namePart type="date">
            <xsl:value-of select="./p:subfield[@code='d']" />
          </mods:namePart>
        </xsl:if>
        <xsl:if test="./p:subfield[@code='g']"> <!-- Zusatz-->
          <mods:namePart>
            <xsl:value-of select="./p:subfield[@code='g']" />
          </mods:namePart>
        </xsl:if>
        <xsl:if test="./p:subfield[@code='c']"> <!-- non-normative type "place" -->
          <mods:namePart>
            <xsl:value-of select="./p:subfield[@code='c']" />
          </mods:namePart>
        </xsl:if>
        <xsl:call-template name="COMMON_CorporateName_ROLES">
          <xsl:with-param name="datafield" select="." />
        </xsl:call-template>
        </mods:name>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="COMMON_CorporateName_ROLES">
      <xsl:param name="datafield"></xsl:param>
      <xsl:choose>
        <xsl:when test="$datafield/p:subfield[@code='4']">
        
         <xsl:for-each select="$datafield/p:subfield[@code='4']">
            <mods:role>
              <xsl:if test="preceding-sibling::p:subfield[@code='B']">
                <mods:roleTerm type="text" authority="GBV">
                  <xsl:value-of select="preceding-sibling::p:subfield[@code='B'][last()]" />
                </mods:roleTerm>
              </xsl:if>
              <mods:roleTerm type="code" authority="marcrelator">
                <xsl:value-of select="." />
              </mods:roleTerm>
            </mods:role>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="$datafield/p:subfield[@code='B']">
        <mods:role>
          <mods:roleTerm type="text" authority="GBV">
            <xsl:value-of select="$datafield/p:subfield[@code='B']" />
          </mods:roleTerm>
        </mods:role>
        </xsl:when>
        <xsl:when test="@tag='033J'">
          <mods:role>
            <mods:roleTerm type="code" authority="marcrelator">pbl</mods:roleTerm>
            <mods:roleTerm type="text" authority="GBV">Verlag</mods:roleTerm>
          </mods:role>
        </xsl:when>
      </xsl:choose>
  </xsl:template>
  
  <xsl:template name="COMMON_ABSTRACT">
    <!--mods:abstract aus 047I mappen und lang-Attribut aus spitzen Klammern am Ende -->
    <xsl:for-each select="./p:datafield[@tag='047I']/p:subfield[@code='a']">
      <mods:abstract type="summary">
        <xsl:choose>
          <xsl:when test="contains(.,'&lt;ger&gt;')">
            <xsl:attribute name="lang">ger</xsl:attribute>
            <xsl:attribute name="xml:lang">de</xsl:attribute>
            <xsl:value-of select="normalize-space(substring-before(., '&lt;ger&gt;'))" />
          </xsl:when>
          <xsl:when test="contains(.,'&lt;eng&gt;')">
            <xsl:attribute name="lang">eng</xsl:attribute>
            <xsl:attribute name="xml:lang">en</xsl:attribute>
            <xsl:value-of select="normalize-space(substring-before(., '&lt;eng&gt;'))" />
          </xsl:when>
          <xsl:when test="contains(.,'&lt;spa&gt;')">
            <xsl:attribute name="lang">spa</xsl:attribute>
            <xsl:attribute name="xml:lang">es</xsl:attribute>
            <xsl:value-of select="normalize-space(substring-before(., '&lt;spa&gt;'))" />
          </xsl:when>
          <xsl:when test="contains(.,'&lt;fra&gt;')">
            <xsl:attribute name="lang">fra</xsl:attribute>
            <xsl:attribute name="xml:lang">fr</xsl:attribute>
            <xsl:value-of select="normalize-space(substring-before(., '&lt;fra&gt;'))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="." />
          </xsl:otherwise>
        </xsl:choose>
      </mods:abstract>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="COMMON_CLASS">
      <!-- ToDoKlassifikationen aus 209O/01 $a mappen -->
    <xsl:for-each select="./p:datafield[@tag='209O']/p:subfield[@code='a' and (starts-with(text(), 'ROSDOK:') or starts-with(text(), 'DBHSNB:'))]">
      <xsl:variable name="class_url" select="concat('classification:', substring-before(substring-after(current(),':'),':'))" />
      <xsl:variable name="class_doc" select="document($class_url)" />
      <xsl:variable name="categid" select="substring-after(substring-after(current(),':'),':')" />
      <xsl:if test="$class_doc//category[@ID=$categid]">
        <xsl:element name="mods:classification">
          <xsl:attribute name="authorityURI"><xsl:value-of select="$class_doc/mycoreclass/label[@xml:lang='x-uri']/@text" /></xsl:attribute>
          <xsl:attribute name="valueURI"><xsl:value-of select="concat($class_doc/mycoreclass/label[@xml:lang='x-uri']/@text,'#', $categid)" /></xsl:attribute>
          <xsl:attribute name="displayLabel"><xsl:value-of select="$class_doc/mycoreclass/@ID" /></xsl:attribute>
          <xsl:value-of select="$class_doc//category[@ID=$categid]/label[@xml:lang='de']/@text" />
        </xsl:element>
      </xsl:if>
    </xsl:for-each>
    <xsl:choose>
    <xsl:when test="./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:doctype:epub')]">
      <xsl:if test="./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:doctype:epub') and not(text() = 'ROSDOK:doctype:epub.series') and not(text() = 'ROSDOK:doctype:epub.journal')]">
        <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:metadata')])">
          <mods:classification displayLabel="licenseinfo" authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo" valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#metadata.cc0">Lizenz Metadaten: CC0</mods:classification>
        </xsl:if>
        <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:deposit')])">
          <mods:classification displayLabel="licenseinfo" authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo" valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#deposit.rightsgranted">Nutzungsrechte erteilt</mods:classification>
        </xsl:if>
        <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:work')])">
          <mods:classification displayLabel="licenseinfo" authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo" valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#work.rightsreserved">alle Rechte vorbehalten</mods:classification>
        </xsl:if>
        <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:accesscondition:openaccess')])">
          <mods:classification displayLabel="accesscondition" authorityURI="http://rosdok.uni-rostock.de/classifications/accesscondition" valueURI="http://rosdok.uni-rostock.de/classifications/accesscondition#openaccess">frei zugänglich (Open Access)</mods:classification>
        </xsl:if>
      </xsl:if>
    </xsl:when>
    <xsl:when test="./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'DBHSNB:doctype:epub')]">
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'DBHSNB:licenseinfo:metadata')])">
        <mods:classification displayLabel="licenseinfo" authorityURI="http://digibib.hs-nb.de/classifications/licenseinfo" valueURI="http://digibib.hs-nb.de/classifications/licenseinfo#metadata.cc0">Lizenz Metadaten: CC0</mods:classification>
      </xsl:if>
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'DBHSNB:licenseinfo:deposit')])">
        <mods:classification displayLabel="licenseinfo" authorityURI="http://digibib.hs-nb.de/classifications/licenseinfo" valueURI="http://digibib.hs-nb.de/classifications/licenseinfo#deposit.rightsgranted">Nutzungsrechte erteilt</mods:classification>
      </xsl:if>
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'DBHSNB:licenseinfo:work')])">
        <mods:classification displayLabel="licenseinfo" authorityURI="http://digibib.hs-nb.de/classifications/licenseinfo" valueURI="http://digibib.hs-nb.de/classifications/licenseinfo#work.rightsreserved">alle Rechte vorbehalten</mods:classification>
      </xsl:if>
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'DBHSNB:accesscondition:openaccess')])">
        <mods:classification displayLabel="accesscondition" authorityURI="http://digibib.hs-nb.de/classifications/licenseinfo" valueURI="http://digibib.hs-nb.de/classifications/accesscondition#openaccess">frei zugänglich (Open Access)</mods:classification>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <!-- default:  'ROSDOK:doctype:histbest' -->
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:metadata')])">
        <mods:classification displayLabel="licenseinfo" authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo" valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#metadata.cc0">Lizenz Metadaten: CC0</mods:classification>
      </xsl:if>
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:digitisedimages')])">
        <mods:classification displayLabel="licenseinfo" authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo" valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#digitisedimages.cclicense.cc-by-sa.v40">Lizenz Digitalisate: CC BY SA 4.0</mods:classification>
      </xsl:if>
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:deposit')])">
        <mods:classification displayLabel="licenseinfo" authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo" valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#deposit.publicdomain">gemeinfrei</mods:classification>
      </xsl:if>
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:work')])">
        <mods:classification displayLabel="licenseinfo" authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo" valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#work.publicdomain">gemeinfrei</mods:classification>
      </xsl:if>
      <xsl:if test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:accesscondition:openaccess')])">
        <mods:classification displayLabel="accesscondition" authorityURI="http://rosdok.uni-rostock.de/classifications/accesscondition" valueURI="http://rosdok.uni-rostock.de/classifications/accesscondition#openaccess">frei zugänglich (Open Access)</mods:classification>
      </xsl:if>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
   <xsl:template name="COMMON_UBR_Class_Doctype">
    <xsl:variable name="pica0500_2" select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
    <xsl:for-each select="./p:datafield[@tag='036E' or @tag='036L']/p:subfield[@code='a']/text()">
      <xsl:variable name="pica4110" select="translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ')" />
      <xsl:for-each select="document('classification:doctype')//category[./label[@xml:lang='x-pica-0500-2']]">
        <xsl:if test="starts-with($pica4110, translate(./label[@xml:lang='x-pica-4110']/@text, 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ')) and contains(./label[@xml:lang='x-pica-0500-2']/@text, $pica0500_2)">
          <xsl:element name="mods:classification">
            <xsl:attribute name="authorityURI">http://rosdok.uni-rostock.de/classifications/doctype</xsl:attribute>
            <xsl:attribute name="valueURI"><xsl:value-of select="concat('http://rosdok.uni-rostock.de/classifications/doctype#', ./@ID)" /></xsl:attribute>
            <xsl:attribute name="displayLabel">doctype</xsl:attribute>
            <xsl:value-of select="./label[@xml:lang='de']/@text" />
          </xsl:element>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="COMMON_UBR_Class_Collection">
    <xsl:for-each select="./p:datafield[@tag='036E' or @tag='036L']/p:subfield[@code='a']/text()">
      <xsl:variable name="pica4110" select="translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ')" />
      <xsl:for-each select="document('classification:collection')//category/label[@xml:lang='x-pica-4110']">
        <xsl:if test="starts-with($pica4110, translate(./@text, 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ'))">
          <xsl:element name="mods:classification">
            <xsl:attribute name="authorityURI">http://rosdok.uni-rostock.de/classifications/collection</xsl:attribute>
            <xsl:attribute name="valueURI"><xsl:value-of select="concat('http://rosdok.uni-rostock.de/classifications/collection#', ./../@ID)" /></xsl:attribute>
            <xsl:attribute name="displayLabel">collection</xsl:attribute>
            <!-- TODO: check after update, if we should switch back to [@xml:lang='de'] -->
            <xsl:value-of select="./../label[@xml:lang='x-pica-4110']/@text" />
          </xsl:element>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="COMMON_UBR_Class_Provider">
    <xsl:variable name="provider_class">
      <xsl:for-each select="./p:datafield[@tag='036E' or @tag='036L']/p:subfield[@code='a']/text()">
        <xsl:variable name="pica4110" select="translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ')" />
        <xsl:for-each select="document('classification:provider')//category/label[@xml:lang='x-pica-4110']">
          <xsl:if test="$pica4110 = translate(./@text, 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ')">
            <xsl:element name="mods:classification">
              <xsl:attribute name="authorityURI">http://rosdok.uni-rostock.de/classifications/provider</xsl:attribute>
              <xsl:attribute name="valueURI"><xsl:value-of select="concat('http://rosdok.uni-rostock.de/classifications/provider#', ./../@ID)" /></xsl:attribute>
              <xsl:attribute name="displayLabel">provider</xsl:attribute>
              <xsl:value-of select="./../label[@xml:lang='de']/@text" />
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <!-- <xsl:when test="$provider_class"> looks better, but does not go into otherwise -->
      <xsl:when test="$provider_class!=''">
        <xsl:copy-of select="$provider_class" />
      </xsl:when>
      <xsl:otherwise>
            <xsl:element name="mods:classification">
              <xsl:attribute name="authorityURI">http://rosdok.uni-rostock.de/classifications/provider</xsl:attribute>
              <xsl:attribute name="valueURI">http://rosdok.uni-rostock.de/classifications/provider#ubr</xsl:attribute>
              <xsl:attribute name="displayLabel">provider</xsl:attribute>
              <xsl:text>Universitätsbibliothek Rostock</xsl:text>
            </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
   <xsl:template name="COMMON_UBR_Class_AADGenres">
      <xsl:for-each select="./p:subfield[@code='9']/text()">
        <xsl:variable name="ppn" select="." />
          <xsl:for-each select="document('classification:aadgenre')//category/label[@xml:lang='x-ppn']">
            <xsl:if test="$ppn = ./@text">
              <xsl:element name="mods:classification">
                <xsl:attribute name="authorityURI">http://rosdok.uni-rostock.de/classifications/aadgenre</xsl:attribute>
                <xsl:attribute name="valueURI"><xsl:value-of select="concat('http://rosdok.uni-rostock.de/classifications/aadgenre#', ./../@ID)" /></xsl:attribute>
                <xsl:attribute name="displayLabel">aadgenre</xsl:attribute>
                <xsl:value-of select="./../label[@xml:lang='de']/@text" />
              </xsl:element>
            </xsl:if>
          </xsl:for-each>
      </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="COMMON_Identifier">
       <xsl:for-each select="./p:datafield[@tag='017C']"> <!-- 4950 (kein eigenes Feld) -->
          <xsl:if test="contains(./p:subfield[@code='u'], '//purl.uni-rostock.de')">
            <mods:identifier type="purl"><xsl:value-of select="./p:subfield[@code='u']" /></mods:identifier>
          </xsl:if>          
      </xsl:for-each>
      
      <xsl:for-each select="./p:datafield[@tag='003@']"> <!--  0100 -->
          <mods:identifier type="PPN"><xsl:value-of select="./p:subfield[@code='0']" /></mods:identifier>          
      </xsl:for-each> 
      <xsl:for-each select="./p:datafield[@tag='004U' and contains(./p:subfield[@code='0'], 'urn:nbn:de:gbv:28')]"> <!-- 2050 -->
          <mods:identifier type="urn"><xsl:value-of select="./p:subfield[@code='0']" /></mods:identifier>
      </xsl:for-each> 
      <xsl:for-each select="./p:datafield[@tag='004V' and contains(./p:subfield[@code='0'], '10.18453/')]"> <!-- 2051 -->
          <mods:identifier type="doi"><xsl:value-of select="./p:subfield[@code='0']" /></mods:identifier>
      </xsl:for-each>
      <xsl:for-each select="./p:datafield[@tag='004P' or @tag='004A' or @tag='004J']/p:subfield[@code='0']"> <!-- ISBN, ISBN einer anderen phys. Form (z.B. printISBN), ISBN der Reproduktion -->
        <mods:identifier type="isbn"> <!-- 200x, ISBN-13 -->
          <xsl:value-of select="." />
        </mods:identifier>
      </xsl:for-each>
      
      <!--  alle VD-Nummern werden OHNE Präfix VDxx ins MODS übertragen -->
      <xsl:for-each select="./p:datafield[@tag='006V']"> <!--  2190 -->
         <xsl:choose>
          <xsl:when test="starts-with(./p:subfield[@code='0'],'VD')">
            <mods:identifier type="vd16"><xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], '16'))" /></mods:identifier>
          </xsl:when>
          <xsl:otherwise>
            <mods:identifier type="vd16"><xsl:value-of select="./p:subfield[@code='0']" /></mods:identifier>
          </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
      <xsl:for-each select="./p:datafield[@tag='006W']"> <!--  2191 -->
         <xsl:choose>
          <xsl:when test="starts-with(./p:subfield[@code='0'],'VD')">
            <mods:identifier type="vd17"><xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], '17'))" /></mods:identifier>
          </xsl:when>
          <xsl:otherwise>
            <mods:identifier type="vd17"><xsl:value-of select="./p:subfield[@code='0']" /></mods:identifier>
          </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
      <xsl:for-each select="./p:datafield[@tag='006M']"> <!--  2192 -->
               <xsl:choose>
          <xsl:when test="starts-with(./p:subfield[@code='0'],'VD')">
            <mods:identifier type="vd18"><xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], '18'))" /></mods:identifier>
          </xsl:when>
          <xsl:otherwise>
            <mods:identifier type="vd18"><xsl:value-of select="./p:subfield[@code='0']" /></mods:identifier>
          </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
      <xsl:for-each select="./p:datafield[@tag='006Z']"> <!--  2110 -->
          <mods:identifier type="zdb"><xsl:value-of select="./p:subfield[@code='0']" /></mods:identifier>          
      </xsl:for-each>       
      <xsl:for-each select="./p:datafield[@tag='007S']"><!-- 2277 -->
        <xsl:choose>
          <!-- VD16 nicht nur in 2190, sondern als bibliogr. Zitat in 2277 -->
          <xsl:when test="starts-with(./p:subfield[@code='0'], 'VD16') or starts-with(./p:subfield[@code='0'], 'VD 16')">
            <xsl:if test="not(./../p:datafield[@tag='006V'])">
              <mods:identifier type="vd16"><xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], '16'))" /></mods:identifier>
            </xsl:if>
          </xsl:when>
          <!-- VD17 nicht nur in 2191, sondern als bibliogr. Zitat in 2277 -->
          <xsl:when test="starts-with(./p:subfield[@code='0'], 'VD17') or starts-with(./p:subfield[@code='0'], 'VD 17')">
            <xsl:if test="not(./../p:datafield[@tag='006W'])">
              <mods:identifier type="vd17"><xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], '17'))" /></mods:identifier>
            </xsl:if>
          </xsl:when>
          <!--VD18 nicht nur in 2192, sondern als bibliogr. Zitat in 2277 -->
          <xsl:when test="starts-with(./p:subfield[@code='0'], 'VD18') or starts-with(./p:subfield[@code='0'], 'VD 18')">
            <xsl:if test="not(./../p:datafield[@tag='006M'])">
                <mods:identifier type="vd18"><xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], '18'))" /></mods:identifier>
            </xsl:if>
          </xsl:when>
          <xsl:when test="starts-with(./p:subfield[@code='0'], 'RISM')">
            <mods:identifier type="rism"><xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], 'RISM'))" /></mods:identifier>
          </xsl:when>
          <xsl:when test="starts-with(./p:subfield[@code='0'], 'Kalliope')">
            <mods:identifier type="kalliope"><xsl:value-of select="normalize-space(substring-after(./p:subfield[@code='0'], 'Kalliope'))" /></mods:identifier>
          </xsl:when>
          <xsl:otherwise>       
            <xsl:if test="not(./p:subfield[@code='S']='e')">
              <mods:note type="bibliographic_reference">
                <xsl:value-of select="./p:subfield[@code='0']" />
              </mods:note>
            </xsl:if>
          </xsl:otherwise> 
        </xsl:choose>
      </xsl:for-each>
    </xsl:template>
  
      <xsl:template name="tokenizeTopics">
		<!--passed template parameter -->
        <xsl:param name="list"/>
        <xsl:param name="delimiter" select="' / '"/>
        <xsl:choose>
            <xsl:when test="contains($list, $delimiter)">                
                <mods:topic>
                    <!-- get everything in front of the first delimiter -->
                    <xsl:value-of select="substring-before($list,$delimiter)"/>
                </mods:topic>
                <xsl:call-template name="tokenizeTopics">
                    <!-- store anything left in another variable -->
                    <xsl:with-param name="list" select="substring-after($list,$delimiter)"/>
                    <xsl:with-param name="delimiter" select="$delimiter"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$list = ''">
                        <xsl:text/>
                    </xsl:when>
                    <xsl:otherwise>
                        <mods:topic>
                            <xsl:value-of select="$list"/>
                        </mods:topic>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
  
</xsl:stylesheet> 