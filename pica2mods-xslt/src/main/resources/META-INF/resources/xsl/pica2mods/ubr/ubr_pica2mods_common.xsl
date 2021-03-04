<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="p xalan fn">

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
        <xsl:if test="(@tag='036D' or @tag='036F') and ./p:subfield[@code='X']"> <!-- 4160, 4180 -->
          <mods:text type="sortstring">
            <xsl:choose>
              <!-- https://stackoverflow.com/a/3857478 -->
              <xsl:when test="(number(./p:subfield[@code='X']) = number(./p:subfield[@code='X'])) and (string-length(./p:subfield[@code='X']) &lt;= 4)">
                <!-- https://stackoverflow.com/a/25662547 -->
                <xsl:value-of select="substring(concat('0000', ./p:subfield[@code='X']), string-length(./p:subfield[@code='X']) + 1, 4)" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="./p:subfield[@code='X']" />
              </xsl:otherwise>
            </xsl:choose>
          </mods:text>
        </xsl:if>
      </mods:part>
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