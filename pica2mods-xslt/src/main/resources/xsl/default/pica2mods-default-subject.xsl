<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="3.0"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
                exclude-result-prefixes="mods pica2mods"
                expand-text="yes">

  <xsl:import use-when="system-property('XSL_TESTING')='true'" href="_common/pica2mods-functions.xsl" />

  <!-- This template is for testing purposes -->
  <xsl:template match="p:record">
    <mods:mods>
      <xsl:call-template name="modsSubject" />
    </mods:mods>
  </xsl:template>

  <xsl:template name="modsSubject">
  <xsl:variable name="picaMode" select="pica2mods:detectPicaMode(.)" />
  <xsl:choose>
    <xsl:when test="$picaMode = 'EPUB'">
      <xsl:for-each select="./p:datafield[@tag='144Z' and @occurrence]"><!-- lokale Schlagworte -->
        <mods:subject>
          <xsl:call-template name="tokenizeTopics">
            <xsl:with-param name="list" select="./p:subfield[@code='a']/text()" />
          </xsl:call-template>
        </mods:subject>
      </xsl:for-each>
    </xsl:when>
  </xsl:choose>
</xsl:template>
  
  <!-- TODO XSLT3-Function -->
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
