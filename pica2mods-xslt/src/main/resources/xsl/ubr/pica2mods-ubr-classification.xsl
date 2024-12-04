<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
                xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:err="http://www.w3.org/2005/xqt-errors"
                exclude-result-prefixes="mods pica2mods p xlink err"
                expand-text="yes">

  <xsl:import use-when="system-property('XSL_TESTING')='true'" href="_common/pica2mods-functions.xsl" />

  <xsl:param name="WebApplicationBaseURL" select="'https://rosdok.uni-rostock.de/'" />
  <!-- This template is for testing purposes -->
  <xsl:template match="p:record">
    <mods:mods>
      <xsl:call-template name="modsClassification" />
    </mods:mods>
  </xsl:template>

  <!-- TODO URIResolver classification: ersetzen mit Funktion -->
  <xsl:template name="modsClassification">
    <xsl:variable name="picaMode" select="pica2mods:detectMode(.)" />

    <xsl:choose>
      <xsl:when test="$picaMode = 'REPRO'">
        <xsl:call-template name="COMMON_UBR_Class_Collection" />
        <xsl:call-template name="COMMON_UBR_Class_Provider" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="EPUB_SDNB">
          <xsl:with-param name="pica" select="." />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="COMMON_CLASS" />
  </xsl:template>

  <xsl:template name="COMMON_CLASS">
    <!-- Klassifikationen aus 209O/01  8600 exemplarspezifische Abrufzeichen mappen
         Doctype-Klassifikation jetzt als mods:Genre (MyCoRe/MIR konform) -->
    <xsl:for-each select="./p:datafield[@tag='209O']/p:subfield[@code='a' and (starts-with(text(), 'ROSDOK:') or starts-with(text(), 'DBHSNB:')) and not(contains(text(), ':doctype:'))]">
      <xsl:variable name="classid" select="substring-before(substring-after(current(),':'),':')" />
      <xsl:variable name="categid" select="substring-after(substring-after(current(),':'),':')" />
      <xsl:try>
        <xsl:variable name="class_doc" select="document(concat('classification:',$classid))" />
        <xsl:if test="$class_doc//category[@ID=$categid]">
          <xsl:element name="mods:classification">
            <xsl:attribute name="authorityURI"><xsl:value-of
              select="$class_doc/mycoreclass/label[@xml:lang='x-uri']/@text" /></xsl:attribute>
            <xsl:attribute name="valueURI"><xsl:value-of
              select="concat($class_doc/mycoreclass/label[@xml:lang='x-uri']/@text,'#', $categid)" /></xsl:attribute>
            <xsl:attribute name="displayLabel"><xsl:value-of select="$class_doc/mycoreclass/@ID" /></xsl:attribute>
            <xsl:value-of select="$class_doc//category[@ID=$categid]/label[@xml:lang='de']/@text" />
          </xsl:element>
        </xsl:if>
        <xsl:catch>
          <xsl:comment>Error resolving classification for 8600 {.}</xsl:comment>
        </xsl:catch>
      </xsl:try>
    </xsl:for-each>
    <xsl:if
      test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and contains(text(), ':licenseinfo:metadata')])">
      <mods:classification displayLabel="licenseinfo"
        authorityURI="{$WebApplicationBaseURL}classifications/licenseinfo"
        valueURI="{$WebApplicationBaseURL}classifications/licenseinfo#metadata.cc0">Lizenz Metadaten: CC0</mods:classification>
    </xsl:if>

    <xsl:choose>
      <xsl:when
        test="./p:datafield[@tag='209O']/p:subfield[@code='a' and (ends-with(text(), ':doctype:epub.series') or ends-with(text(), ':doctype:epub.journal'))]">
        <!-- Schriftenreihe oder Zeitschrift (Bundle) keine Default-Klassifikationen für licenseInfo und acessCondition -->
      </xsl:when>
      <xsl:when test="./p:datafield[@tag='209O']/p:subfield[@code='a' and (contains(text(), ':doctype:epub') or contains(text(), ':doctype:data'))]">
		<!-- epub / data -keine Default-Klassifikationen -->
      </xsl:when>
      <xsl:otherwise>
        <!-- default: Histbest (kein ':doctype:histbest' im Pica!) -->
        <xsl:if
          test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and contains(text(), ':licenseinfo:digitisedimages')])">
          <mods:classification displayLabel="licenseinfo"
            authorityURI="{$WebApplicationBaseURL}classifications/licenseinfo"
            valueURI="{$WebApplicationBaseURL}classifications/licenseinfo#digitisedimages.norestrictions">Keine Einschränkungen</mods:classification>
        </xsl:if>
        <xsl:if
          test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and contains(text(), ':licenseinfo:deposit')])">
          <mods:classification displayLabel="licenseinfo"
            authorityURI="{$WebApplicationBaseURL}classifications/licenseinfo"
            valueURI="{$WebApplicationBaseURL}classifications/licenseinfo#deposit.publicdomain">gemeinfrei</mods:classification>
        </xsl:if>
        <xsl:if
          test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and contains(text(), ':licenseinfo:work')])">
          <mods:classification displayLabel="licenseinfo"
            authorityURI="{$WebApplicationBaseURL}classifications/licenseinfo"
            valueURI="{$WebApplicationBaseURL}classifications/licenseinfo#work.publicdomain">gemeinfrei</mods:classification>
        </xsl:if>
        <xsl:if
          test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and contains(text(), ':accesscondition')])">
          <mods:classification displayLabel="accesscondition"
            authorityURI="{$WebApplicationBaseURL}classifications/accesscondition"
            valueURI="{$WebApplicationBaseURL}classifications/accesscondition#openaccess">frei zugänglich (Open Access)</mods:classification>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="COMMON_UBR_Class_Doctype">
    <xsl:variable name="pica0500_2"
      select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />    <!-- 4170, 4110 | 4238  -->
    <xsl:for-each select="./p:datafield[@tag='036E' or @tag='036L']/p:subfield[@code='a']/text() | ./p:datafield[@tag='037J']/p:subfield[@code='f']/text()">
      <xsl:variable name="pica4110" select="lower-case(.)" />
      <xsl:for-each
        select="document('classification:doctype')//category[./label[@xml:lang='x-pica-0500-2']]">
        <xsl:if
          test="starts-with($pica4110, lower-case(./label[@xml:lang='x-pica-4110']/@text)) and contains(./label[@xml:lang='x-pica-0500-2']/@text, $pica0500_2)">
          <xsl:element name="mods:classification">
            <xsl:attribute name="authorityURI">{$WebApplicationBaseURL}classifications/doctype</xsl:attribute>
            <xsl:attribute name="valueURI">{$WebApplicationBaseURL}classifications/doctype#'{./@ID}</xsl:attribute>
            <xsl:attribute name="displayLabel">doctype</xsl:attribute>
            <xsl:value-of select="./label[@xml:lang='de']/@text" />
          </xsl:element>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="COMMON_UBR_Class_Collection">
    <xsl:for-each select="./p:datafield[@tag='036E' or @tag='036L']/p:subfield[@code='a']/text()) | ./p:datafield[@tag='037J']/p:subfield[@code='f']/text()">
      <xsl:variable name="pica4110" select="lower-case(.)" />
      <xsl:for-each select="document('classification:collection')//category/label[@xml:lang='x-pica-4110']">
        <xsl:if test="starts-with($pica4110, lower-case(./@text))">
          <xsl:element name="mods:classification">
            <xsl:attribute name="authorityURI">{$WebApplicationBaseURL}classifications/collection</xsl:attribute>
            <xsl:attribute name="valueURI">{$WebApplicationBaseURL}classifications/collection#{./../@ID}</xsl:attribute>
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
      <xsl:for-each select="./p:datafield[@tag='036E' or @tag='036L']/p:subfield[@code='a']/text() ) | ./p:datafield[@tag='037J']/p:subfield[@code='f']/text()">
        <xsl:variable name="pica4110" select="lower-case(.)" />
        <xsl:for-each select="document('classification:provider')//category/label[@xml:lang='x-pica-4110']">
          <xsl:if test="$pica4110 = lower-case(./@text)">
            <xsl:element name="mods:classification">
              <xsl:attribute name="authorityURI">{$WebApplicationBaseURL}classifications/provider</xsl:attribute>
              <xsl:attribute name="valueURI">{$WebApplicationBaseURL}classifications/provider#{./../@ID}</xsl:attribute>
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
          <xsl:attribute name="authorityURI">{$WebApplicationBaseURL}classifications/provider</xsl:attribute>
          <xsl:attribute name="valueURI">{$WebApplicationBaseURL}classifications/provider#ubr</xsl:attribute>
          <xsl:attribute name="displayLabel">provider</xsl:attribute>
          <xsl:text>Universitätsbibliothek Rostock</xsl:text>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- TODO SDNB - Klassifiation ist ein Fall für default .... -->
  <xsl:template name="EPUB_SDNB">
    <xsl:param name="pica" />
    <xsl:for-each select="document('classification:SDNB')//category">
      <xsl:if test="$pica/p:datafield[@tag='045F']/p:subfield[@code='a'] = ./@ID">
        <xsl:element name="mods:classification">
          <xsl:attribute name="authorityURI">{$WebApplicationBaseURL}classifications/SDNB</xsl:attribute>
          <xsl:attribute name="valueURI">{$WebApplicationBaseURL}classifications/SDNB#{./@ID}</xsl:attribute>
          <xsl:attribute name="displayLabel">sdnb</xsl:attribute>
          <xsl:value-of select="./label[@xml:lang='de']/@text" />
        </xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>
  