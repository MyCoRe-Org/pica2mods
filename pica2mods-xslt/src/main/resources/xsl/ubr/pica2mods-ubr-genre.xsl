<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions" 
                xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="mods pica2mods p xlink"
                expand-text="yes">

  <xsl:import use-when="system-property('XSL_TESTING')='true'" href="_common/pica2mods-functions.xsl" />

  <!-- This template is for testing purposes -->
  <xsl:template match="p:record">
    <mods:mods>
      <xsl:call-template name="UBR_modsGenre_Doctype" />
    </mods:mods>
  </xsl:template>

    <xsl:template name="UBR_modsGenre_Doctype">
    <xsl:choose>
      <xsl:when test="./p:datafield[@tag='209O']/p:subfield[@code='a' and (starts-with(text(), 'ROSDOK:') or starts-with(text(), 'DBHSNB:')) and contains(text(), ':doctype:')]">
        <xsl:for-each select="./p:datafield[@tag='209O']/p:subfield[@code='a' and (starts-with(text(), 'ROSDOK:') or starts-with(text(), 'DBHSNB:')) and contains(text(), ':doctype:')]">
          <xsl:variable name="classid" select="substring-before(substring-after(current(),':'),':')" />
          <xsl:variable name="categid" select="substring-after(substring-after(current(),':'),':')" />
    
          <xsl:variable name="class_doc" select="document(concat('classification:',$classid))" />
          <xsl:if test="$class_doc//category[@ID=$categid]">
            <xsl:element name="mods:genre">
              <xsl:attribute name="usage">primary</xsl:attribute>
              <xsl:attribute name="type">intern</xsl:attribute>
              <xsl:attribute name="displayLabel"><xsl:value-of select="$class_doc/mycoreclass/@ID" /></xsl:attribute>
              <xsl:attribute name="authorityURI">
                <xsl:value-of select="$class_doc/mycoreclass/label[@xml:lang='x-uri']/@text" />
              </xsl:attribute>
              <xsl:attribute name="valueURI">
                <xsl:value-of select="concat($class_doc/mycoreclass/label[@xml:lang='x-uri']/@text,'#', $categid)" />
              </xsl:attribute>
              <xsl:value-of select="$class_doc//category[@ID=$categid]/label[@xml:lang='de']/@text" />
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="pica0500_2" select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
        <xsl:for-each select="./p:datafield[@tag='036E' or @tag='036L']/p:subfield[@code='a']/text()">
          <xsl:variable name="pica4110" select="lower-case(.)" />
          <xsl:for-each select="document('classification:doctype')//category[./label[@xml:lang='x-pica-0500-2']]">
            <xsl:if test="starts-with($pica4110, lower-case(./label[@xml:lang='x-pica-4110']/@text)) and contains(./label[@xml:lang='x-pica-0500-2']/@text, $pica0500_2)">
              <xsl:element name="mods:genre">
                <xsl:attribute name="type">intern</xsl:attribute>
                <xsl:attribute name="usage">primary</xsl:attribute>
                <xsl:attribute name="displayLabel">doctype</xsl:attribute>
                <xsl:attribute name="authorityURI">{$WebApplicationBaseURL}classifications/doctype</xsl:attribute>
                <xsl:attribute name="valueURI">{$WebApplicationBaseURL}classifications/doctype#{./@ID}</xsl:attribute>
                <xsl:value-of select="./label[@xml:lang='de']/@text" />
              </xsl:element>
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
