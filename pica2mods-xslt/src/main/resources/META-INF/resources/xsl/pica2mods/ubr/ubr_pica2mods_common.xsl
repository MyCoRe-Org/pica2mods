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