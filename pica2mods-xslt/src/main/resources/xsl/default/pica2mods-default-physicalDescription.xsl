<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
                xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="mods pica2mods">

  <xsl:import use-when="system-property('XSL_TESTING')='true'" href="_common/pica2mods-functions.xsl" />

  <!-- This template is for testing purposes -->
  <xsl:template match="p:record">
    <mods:mods>
      <xsl:call-template name="modsPhysicalDescription" />
    </mods:mods>
  </xsl:template>

  <xsl:template name="modsPhysicalDescription">
    <xsl:variable name="picaMode" select="pica2mods:detectPicaMode(.)" />
    <xsl:choose>
      <xsl:when test="$picaMode = 'REPRO'">
        <xsl:call-template name="modsPhysicalDescriptionRepro" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="modsPhysicalDescriptionDefault" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="modsPhysicalDescriptionDefault">
    <xsl:for-each select="./p:datafield[@tag='034D']/p:subfield[@code='a']">
      <mods:physicalDescription>
        <mods:extent>
          <xsl:value-of select="." />
        </mods:extent>
      </mods:physicalDescription>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="modsPhysicalDescriptionRepro">
    <xsl:variable name="pica0500_2"
      select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />

    <xsl:choose>
      <xsl:when test="not($pica0500_2='v')">
        <xsl:variable name="digitalOrigin">
          <xsl:call-template name="physicalDescriptionDigitalOrigin">
            <xsl:with-param name="record" select="." />
          </xsl:call-template>
        </xsl:variable>

        <!-- RDA -->
        <xsl:variable name="picaA" select="pica2mods:queryPicaDruck(.)" />
        <xsl:choose>
          <xsl:when test="$picaA/p:datafield[@tag='034D' or @tag='034M' or @tag='034I' or @tag='034K']">
            <mods:physicalDescription>
              <xsl:call-template name="physicalDescriptionContent">
                <xsl:with-param name="record" select="$picaA" />
              </xsl:call-template>
              <xsl:copy-of select="$digitalOrigin" />
            </mods:physicalDescription>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="./p:datafield[@tag='034D' or @tag='034M' or @tag='034I' or @tag='034K']">
              <mods:physicalDescription>
                <xsl:call-template name="physicalDescriptionContent">
                  <xsl:with-param name="record" select="." />
                </xsl:call-template>
                <xsl:copy-of select="$digitalOrigin" />
              </mods:physicalDescription>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <mods:physicalDescription>
          <xsl:for-each select="./p:datafield[@tag='034D']/p:subfield[@code='a']">   <!-- 4060 Umfang, Seiten aus O-Aufnahme, Problem: "1 Online-Ressource (...)" -->
            <mods:extent>
              <xsl:value-of select="." />
            </mods:extent>
          </xsl:for-each>
          <xsl:call-template name="physicalDescriptionDigitalOrigin">
            <xsl:with-param name="record" select="." />
          </xsl:call-template>
        </mods:physicalDescription>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="physicalDescriptionContent">
    <xsl:param name="record" />
    <xsl:for-each select="$record/p:datafield[@tag='034D']/p:subfield[@code='a']">   <!-- 4060 Umfang, Seiten -->
      <mods:extent>
        <xsl:value-of select="." />
      </mods:extent>
    </xsl:for-each>
    <xsl:for-each select="$record/p:datafield[@tag='034M']/p:subfield[@code='a']">   <!-- 4061 Illustrationen -->
      <mods:note type="content">
        <xsl:value-of select="." />
      </mods:note>
    </xsl:for-each>
    <xsl:for-each select="$record/p:datafield[@tag='034I']/p:subfield[@code='a']">   <!-- 4062 Format, Größe -->
      <mods:note type="source_dimensions">
        <xsl:value-of select="." />
      </mods:note>
    </xsl:for-each>
    <xsl:for-each select="$record/p:datafield[@tag='034K']/p:subfield[@code='a']">   <!-- 4063 Begleitmaterial -->
      <mods:note type='content'>
        <xsl:value-of select="." />
      </mods:note>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="physicalDescriptionDigitalOrigin">
    <xsl:param name="record" />
    <xsl:variable name="pica0500" select="$record/p:datafield[@tag='002@']/p:subfield[@code='0']" />
    <xsl:if test="starts-with($pica0500, 'O')">
      <xsl:choose>  <!-- 4238 Technische Angaben zum elektr. Dokument, RDA ok -->
        <xsl:when
          test="contains($record/p:datafield[@tag='037H']/p:subfield[@code='a'], 'Digitalisierungsvorlage: Original')"> <!-- alt -->
          <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
        </xsl:when>
        <xsl:when
          test="contains($record/p:datafield[@tag='037H']/p:subfield[@code='a'], 'Digitalisierungsvorlage: Primärausgabe')">
          <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
        </xsl:when>
        <xsl:when
          test="contains($record/p:datafield[@tag='037H']/p:subfield[@code='a'], 'Digitalisierungsvorlage: Mikrofilm')">
          <mods:digitalOrigin>digitized microfilm</mods:digitalOrigin>
        </xsl:when>
        <xsl:otherwise>
          <mods:digitalOrigin>reformatted digital</mods:digitalOrigin>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
