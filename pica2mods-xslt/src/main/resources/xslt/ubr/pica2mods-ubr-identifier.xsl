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
      <xsl:call-template name="UBR_modsIdentifier" />
    </mods:mods>
  </xsl:template>

  <!-- TODO Die RecordID aus der PURL zu übernehmen ist nicht schön und tendenziell fehleranfällig, kann man dafür nicht 
    ein "unsichtbares" Sigel im Exemplarsatz belegen -->
  <xsl:template name="UBR_modsIdentifier">
    <xsl:variable name="picaMode" select="pica2mods:detectMode(.)" />

    <xsl:for-each select="./p:datafield[@tag='017C']"> <!-- 4950 (kein eigenes Feld) -->
      <xsl:if test="contains(./p:subfield[@code='u'], '://purl.uni-rostock.de')">
        <mods:identifier type="purl">
          <xsl:value-of select="replace(./p:subfield[@code='u'], 'http://', 'https://')" />
        </mods:identifier>
      </xsl:if>
    </xsl:for-each>
    
    <xsl:if test="(not(./p:datafield[@tag='004U']/p:subfield[@code='0' and starts-with(., 'urn:nbn:de:gbv:28-')])
                  and not(./p:datafield[@tag='004U']/p:subfield[@code='0' and starts-with(., 'urn:nbn:de:gbv:519-')])
                  and ./p:datafield[@tag='002@']/p:subfield[@code='0' and contains('afFsv', substring(.,2,1))])">
      <xsl:variable name="recordID" select="substring-after(substring(./p:datafield[@tag='017C']/p:subfield[@code='u' and contains(., '://purl.uni-rostock.de')][1],9), '/')" /> <!-- 4950 URL (recordID from PURL) -->
      <xsl:if test="string-length($recordID) > 0">
        <mods:identifier type="urn">
          <xsl:value-of select="pica2mods:createURNWithChecksumForURNBase(concat('urn:nbn:de:gbv:28-', replace($recordID,'/','_'),'-'))" />
        </mods:identifier>
      </xsl:if>
    </xsl:if>

    <xsl:for-each
      select="./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(., 'ROSDOK_MD:openaire:')]"> <!-- ISBN einer anderen Ausgabe (z.B. printISBN) -->
      <mods:identifier type="openaire"> <!-- 2000, ISBN-13 -->
        <xsl:value-of select="substring(., 20)" />
      </mods:identifier>
    </xsl:for-each>

  </xsl:template>

</xsl:stylesheet>
