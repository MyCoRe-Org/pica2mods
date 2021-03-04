<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="p xalan fn">
  <xsl:import href="cp:ubr/ubr_pica2mods_common.xsl" />
  <xsl:variable name="XSL_VERSION_EPUB" select="concat('ubr_pica2mods_EPUB.xsl from ',$XSL_VERSION_PICA2MODS)" />
  <xsl:template match="/p:record" mode="EPUB">
    
    <xsl:for-each select="./p:datafield[@tag='034D']/p:subfield[@code='a' and contains(., 'Seite')]">
      <mods:physicalDescription>
        <mods:extent unit="pages"><xsl:value-of select="normalize-space(substring-before(substring-after(.,'('),'Seite'))" /></mods:extent>
      </mods:physicalDescription>
    </xsl:for-each>
    
   
    

    <xsl:for-each select="./p:datafield[@tag='037A']"><!-- Gutachter in Anmerkungen -->
      <xsl:choose>
        <xsl:when test="starts-with(./p:subfield[@code='a'], 'GutachterInnen:')">
            <mods:note type="referee">
              <xsl:value-of select="substring-after(./p:subfield[@code='a'], 'GutachterInnen: ')" />
            </mods:note>
        </xsl:when>
        <xsl:otherwise>
            <mods:note type="other">
              <xsl:value-of select="./p:subfield[@code='a']" />
            </mods:note>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='037B' or @tag='046L' or @tag='046F' or @tag='046G' or @tag='046H' or @tag='046I']"><!-- 4201, 4202, 4221, 4215, 4216, 4217, 4218 RDA raus 4202, 4215, 4216 neu 4210, 4212, 4221, 4223, 4226 (einfach den ganzen Anmerkungskrams mitnehmen" -->
      <mods:note type="other">
        <xsl:value-of select="./p:subfield[@code='a']" />
      </mods:note>
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='047C' or @tag='022A']">
      <!-- 4200 (047C, abweichende Sucheinstiege, RDA zusätzlich:3210 (022A, Werktitel) und 3260 (027A, abweichender Titel) -->
      <mods:note type="titlewordindex">
        <xsl:value-of select="./p:subfield[@code='a']" />
      </mods:note>
    </xsl:for-each>

  </xsl:template>

</xsl:stylesheet> 