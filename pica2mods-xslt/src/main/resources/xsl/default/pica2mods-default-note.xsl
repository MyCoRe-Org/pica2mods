<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
                xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="mods pica2mods p xlink">

  <xsl:import use-when="system-property('XSL_TESTING')='true'" href="_common/pica2mods-functions.xsl" />

  <!-- This template is for testing purposes -->
  <xsl:template match="p:record">
    <mods:mods>
      <xsl:call-template name="modsNote" />
    </mods:mods>
  </xsl:template>

  <xsl:template name="modsNote">
    <xsl:variable name="picaMode" select="pica2mods:detectMode(.)" />
    <xsl:choose>
      <xsl:when test="$picaMode = 'REPRO'">
        <xsl:call-template name="common_source_note" />
      </xsl:when>
      <xsl:otherwise>
        <!-- Für EPUB - besondere Behandlung der Gutachter
             und aufsammeln der sonstigen Anmerkungen in type='other' statt type='source_note' -->
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
      
        <!-- UBR Details zu Personen -->
        <xsl:for-each
          select="./p:datafield[@tag='220B']/p:subfield[@code='a' and starts-with(., 'personal_details:')]">
          <mods:note type="personal_details">
            <xsl:value-of select="normalize-space(substring-after(., 'personal_details:'))" />
          </mods:note>
        </xsl:for-each>
        
        <!-- UBR Details zu anderen Lizenzen -->
        <xsl:for-each
          select="./p:datafield[@tag='220B']/p:subfield[@code='a' and starts-with(., 'license_other:')]">
          <mods:note type="license_other">
            <xsl:value-of select="normalize-space(substring-after(., 'license_other:'))" />
          </mods:note>
        </xsl:for-each>

        <!-- Hochschulschriftenvermerk -->
        <!-- Nicht RDA [037C/a] -->
        <xsl:if test="./p:datafield[@tag='037C']/p:subfield[@code='a']">
          <mods:note type="university_thesis_note">
            <xsl:value-of select="./p:datafield[@tag='037C'][1]/p:subfield[@code='a']" />
          </mods:note>
        </xsl:if>

        <!-- RDA [037C/d], [037C/e], [037C/f] {, [037C/g]} -->
        <xsl:if test="./p:datafield[@tag='037C']/p:subfield[@code='d' or @code='e' or @code='f' or @code='g']">
          <mods:note type="university_thesis_note">
            <xsl:value-of select="string-join(./p:datafield[@tag='037C']/p:subfield[@code='d' or @code='e' or @code='f' or @code='g'], ', ')"/>
          </mods:note>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:call-template name="common_reproduction_note" />
    <xsl:call-template name="common_external_link_note" />
    <xsl:call-template name="common_titleword_index" />
    <xsl:call-template name="common_statement_of_responsibility" />
    <xsl:call-template name="common_available_volumes" />
  </xsl:template>

  <xsl:template name="common_statement_of_responsibility">
    <xsl:if test="./p:datafield[@tag='021A']/p:subfield[@code='h']">
      <mods:note type="statement of responsibility">
        <xsl:value-of select="./p:datafield[@tag='021A']/p:subfield[@code='h']" />
      </mods:note>
    </xsl:if>
  </xsl:template>

  <xsl:template name="common_titleword_index"> <!-- 4200 abweichende Sucheinstiege --> 
    <xsl:for-each select="./p:datafield[@tag='047C']">
      <mods:note type="titlewordindex">
        <xsl:value-of select="./p:subfield[@code='a']" />
      </mods:note>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="common_external_link_note"> <!-- 4961 URL für sonstige Angaben zur Resource -->
    <xsl:for-each select="./p:datafield[@tag='017H']">
      <mods:note type="external_link">
        <xsl:attribute name="xlink:href">
                    <xsl:value-of select="./p:subfield[@code='u']" />
                </xsl:attribute>
        <xsl:value-of select="./p:subfield[@code='y']" />
      </mods:note>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="common_reproduction_note">
    <xsl:for-each select="./p:datafield[@tag='037G']"> <!-- 4237 Anmerkungen zur Reproduktion -->
      <mods:note type="reproduction">
        <xsl:value-of select="./p:subfield[@code='a']" />
      </mods:note>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="common_source_note">
    <xsl:for-each
      select="./p:datafield[@tag='037A' or @tag='037B' or @tag='046L' or @tag='046F' or @tag='046G' or @tag='046H' or @tag='046I' or @tag='046P']"><!-- 4201, 4202, 4221, 4215, 4216, 4217, 4218 RDA raus 4202, 4215, 4216 neu 4210, 4212, 4221, 4223, 4225, 4226 
        (einfach den ganzen Anmerkungskrams mitnehmen) -->
      <mods:note type="source_note">
        <xsl:value-of select="./p:subfield[@code='a']" />
      </mods:note>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="common_available_volumes"> <!-- URL, digitalisierte Ausgaben in interner Bemerkung / nur Ob-Sätze -->
    <xsl:variable name="pica0500_2"
      select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
    <xsl:if test="$pica0500_2='b'">
      <xsl:for-each select="./p:datafield[@tag='017C']/p:subfield[@code='x']">
        <mods:note type="available_volumes{if (contains(../p:subfield[@code='u'], '://purl.uni-rostock.de')) then ('@DE-28') else ('')}">
          <xsl:value-of select="substring-after(.,'; ')" />
        </mods:note>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
    
</xsl:stylesheet>
