<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="3.0"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
                exclude-result-prefixes="mods pica2mods">

  <xsl:import use-when="system-property('XSL_TESTING')='true'" href="_common/pica2mods-functions.xsl" />

  <!-- This template is for testing purposes -->
  <xsl:template match="p:record">
    <mods:mods>
      <xsl:call-template name="modsClassification" />
    </mods:mods>
  </xsl:template>

<!-- TODO URIResolver classification: ersetzen mit Funktion -->
  <xsl:template name="modsClassification">
    <xsl:variable name="picaMode" select="pica2mods:detectPicaMode(.)" />
    <xsl:choose>
      <xsl:when test="$picaMode = 'RDA'">
        <!-- TODO: Gattungsbegriffe AAD aus A- und O-Aufnahme? ggf. Deduplizieren -->
        <xsl:variable name="picaA" select="pica2mods:queryPicaDruck(.)" />
        <xsl:for-each select="$picaA/p:record/p:datafield[@tag='044S']"> <!-- 5570 Gattungsbegriffe AAD, RDA aus A-Aufnahme -->
          <mods:genre type="aadgenre">
            <xsl:value-of select="./p:subfield[@code='a']" />
          </mods:genre>
          <xsl:call-template name="COMMON_UBR_Class_AADGenres" />
        </xsl:for-each>

        <xsl:for-each select="./p:datafield[@tag='044S']"> <!-- 5570 Gattungsbegriffe AAD -->
          <mods:genre type="aadgenre">
            <xsl:value-of select="./p:subfield[@code='a']" />
          </mods:genre>
          <xsl:call-template name="COMMON_UBR_Class_AADGenres" />
        </xsl:for-each>

        <xsl:call-template name="COMMON_UBR_Class_Collection" />
        <xsl:call-template name="COMMON_UBR_Class_Provider" />
        <xsl:call-template name="COMMON_UBR_Class_Doctype" />
        <xsl:call-template name="COMMON_CLASS" />

      </xsl:when>
      <xsl:when test="$picaMode = 'KXP'">
        <xsl:for-each select="./p:datafield[@tag='044S']"> <!-- 5570 Gattungsbegriffe AAD -->
          <mods:genre type="aadgenre">
            <xsl:value-of select="./p:subfield[@code='a']" />
          </mods:genre>
          <xsl:call-template name="COMMON_UBR_Class_AADGenres" />
        </xsl:for-each>

        <xsl:call-template name="COMMON_UBR_Class_Collection" />
        <xsl:call-template name="COMMON_UBR_Class_Provider" />
        <xsl:call-template name="COMMON_UBR_Class_Doctype" />
        <xsl:call-template name="COMMON_CLASS" />
      </xsl:when>
      <xsl:when test="$picaMode = 'EPUB'">
        <xsl:call-template name="EPUB_SDNB">
          <xsl:with-param name="pica" select="." />
        </xsl:call-template>
        <xsl:call-template name="COMMON_CLASS" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="COMMON_CLASS">
    <!-- ToDoKlassifikationen aus 209O/01 $a mappen -->
    <xsl:for-each
      select="./p:datafield[@tag='209O']/p:subfield[@code='a' and (starts-with(text(), 'ROSDOK:') or starts-with(text(), 'DBHSNB:'))]">
      <xsl:variable name="class_url"
        select="concat('classification:', substring-before(substring-after(current(),':'),':'))" />
      <xsl:variable name="class_doc" select="document($class_url)" />
      <xsl:variable name="categid" select="substring-after(substring-after(current(),':'),':')" />
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
    </xsl:for-each>
    <xsl:choose>
      <xsl:when
        test="./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:doctype:epub')]">
        <xsl:if
          test="./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:doctype:epub') and not(text() = 'ROSDOK:doctype:epub.series') and not(text() = 'ROSDOK:doctype:epub.journal')]">
          <xsl:if
            test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:metadata')])">
            <mods:classification displayLabel="licenseinfo"
              authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo"
              valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#metadata.cc0">Lizenz Metadaten: CC0</mods:classification>
          </xsl:if>
          <xsl:if
            test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:deposit')])">
            <mods:classification displayLabel="licenseinfo"
              authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo"
              valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#deposit.rightsgranted">Nutzungsrechte erteilt</mods:classification>
          </xsl:if>
          <xsl:if
            test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:work')])">
            <mods:classification displayLabel="licenseinfo"
              authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo"
              valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#work.rightsreserved">alle Rechte vorbehalten</mods:classification>
          </xsl:if>
          <xsl:if
            test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:accesscondition:openaccess')])">
            <mods:classification displayLabel="accesscondition"
              authorityURI="http://rosdok.uni-rostock.de/classifications/accesscondition"
              valueURI="http://rosdok.uni-rostock.de/classifications/accesscondition#openaccess">frei zugänglich (Open Access)</mods:classification>
          </xsl:if>
        </xsl:if>
      </xsl:when>
      <xsl:when
        test="./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'DBHSNB:doctype:epub')]">
        <xsl:if
          test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'DBHSNB:licenseinfo:metadata')])">
          <mods:classification displayLabel="licenseinfo"
            authorityURI="http://digibib.hs-nb.de/classifications/licenseinfo"
            valueURI="http://digibib.hs-nb.de/classifications/licenseinfo#metadata.cc0">Lizenz Metadaten: CC0</mods:classification>
        </xsl:if>
        <xsl:if
          test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'DBHSNB:licenseinfo:deposit')])">
          <mods:classification displayLabel="licenseinfo"
            authorityURI="http://digibib.hs-nb.de/classifications/licenseinfo"
            valueURI="http://digibib.hs-nb.de/classifications/licenseinfo#deposit.rightsgranted">Nutzungsrechte erteilt</mods:classification>
        </xsl:if>
        <xsl:if
          test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'DBHSNB:licenseinfo:work')])">
          <mods:classification displayLabel="licenseinfo"
            authorityURI="http://digibib.hs-nb.de/classifications/licenseinfo"
            valueURI="http://digibib.hs-nb.de/classifications/licenseinfo#work.rightsreserved">alle Rechte vorbehalten</mods:classification>
        </xsl:if>
        <xsl:if
          test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'DBHSNB:accesscondition:openaccess')])">
          <mods:classification displayLabel="accesscondition"
            authorityURI="http://digibib.hs-nb.de/classifications/licenseinfo"
            valueURI="http://digibib.hs-nb.de/classifications/accesscondition#openaccess">frei zugänglich (Open Access)</mods:classification>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <!-- default: 'ROSDOK:doctype:histbest' -->
        <xsl:if
          test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:metadata')])">
          <mods:classification displayLabel="licenseinfo"
            authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo"
            valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#metadata.cc0">Lizenz Metadaten: CC0</mods:classification>
        </xsl:if>
        <xsl:if
          test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:digitisedimages')])">
          <mods:classification displayLabel="licenseinfo"
            authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo"
            valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#digitisedimages.cclicense.cc-by-sa.v40">Lizenz Digitalisate: CC BY SA 4.0</mods:classification>
        </xsl:if>
        <xsl:if
          test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:deposit')])">
          <mods:classification displayLabel="licenseinfo"
            authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo"
            valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#deposit.publicdomain">gemeinfrei</mods:classification>
        </xsl:if>
        <xsl:if
          test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:licenseinfo:work')])">
          <mods:classification displayLabel="licenseinfo"
            authorityURI="http://rosdok.uni-rostock.de/classifications/licenseinfo"
            valueURI="http://rosdok.uni-rostock.de/classifications/licenseinfo#work.publicdomain">gemeinfrei</mods:classification>
        </xsl:if>
        <xsl:if
          test="not(./p:datafield[@tag='209O']/p:subfield[@code='a' and starts-with(text(), 'ROSDOK:accesscondition:openaccess')])">
          <mods:classification displayLabel="accesscondition"
            authorityURI="http://rosdok.uni-rostock.de/classifications/accesscondition"
            valueURI="http://rosdok.uni-rostock.de/classifications/accesscondition#openaccess">frei zugänglich (Open Access)</mods:classification>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="COMMON_UBR_Class_Doctype">
    <xsl:variable name="pica0500_2"
      select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
    <xsl:for-each select="./p:datafield[@tag='036E' or @tag='036L']/p:subfield[@code='a']/text()">
      <xsl:variable name="pica4110"
        select="translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ')" />
      <xsl:for-each
        select="document('classification:doctype')//category[./label[@xml:lang='x-pica-0500-2']]">
        <xsl:if
          test="starts-with($pica4110, translate(./label[@xml:lang='x-pica-4110']/@text, 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ')) and contains(./label[@xml:lang='x-pica-0500-2']/@text, $pica0500_2)">
          <xsl:element name="mods:classification">
            <xsl:attribute name="authorityURI">http://rosdok.uni-rostock.de/classifications/doctype</xsl:attribute>
            <xsl:attribute name="valueURI"><xsl:value-of
              select="concat('http://rosdok.uni-rostock.de/classifications/doctype#', ./@ID)" /></xsl:attribute>
            <xsl:attribute name="displayLabel">doctype</xsl:attribute>
            <xsl:value-of select="./label[@xml:lang='de']/@text" />
          </xsl:element>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="COMMON_UBR_Class_Collection">
    <xsl:for-each select="./p:datafield[@tag='036E' or @tag='036L']/p:subfield[@code='a']/text()">
      <xsl:variable name="pica4110"
        select="translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ')" />
      <xsl:for-each select="document('classification:collection')//category/label[@xml:lang='x-pica-4110']">
        <xsl:if
          test="starts-with($pica4110, translate(./@text, 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ'))">
          <xsl:element name="mods:classification">
            <xsl:attribute name="authorityURI">http://rosdok.uni-rostock.de/classifications/collection</xsl:attribute>
            <xsl:attribute name="valueURI"><xsl:value-of
              select="concat('http://rosdok.uni-rostock.de/classifications/collection#', ./../@ID)" /></xsl:attribute>
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
        <xsl:variable name="pica4110"
          select="translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ')" />
        <xsl:for-each select="document('classification:provider')//category/label[@xml:lang='x-pica-4110']">
          <xsl:if
            test="$pica4110 = translate(./@text, 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ')">
            <xsl:element name="mods:classification">
              <xsl:attribute name="authorityURI">http://rosdok.uni-rostock.de/classifications/provider</xsl:attribute>
              <xsl:attribute name="valueURI"><xsl:value-of
                select="concat('http://rosdok.uni-rostock.de/classifications/provider#', ./../@ID)" /></xsl:attribute>
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
            <xsl:attribute name="valueURI"><xsl:value-of
              select="concat('http://rosdok.uni-rostock.de/classifications/aadgenre#', ./../@ID)" /></xsl:attribute>
            <xsl:attribute name="displayLabel">aadgenre</xsl:attribute>
            <xsl:value-of select="./../label[@xml:lang='de']/@text" />
          </xsl:element>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!-- TODO SDNB - Klassifiation ist ein Fall für default .... -->
  <xsl:template name="EPUB_SDNB">
    <xsl:param name="pica" />
    <xsl:for-each select="document('classification:SDNB')//category">
      <xsl:if test="$pica/p:datafield[@tag='045F']/p:subfield[@code='a'] = ./@ID">
        <xsl:element name="mods:classification">
          <xsl:attribute name="authorityURI"><xsl:value-of
            select="concat($WebApplicationBaseURL,'classifications/SDNB')" /></xsl:attribute>
          <xsl:attribute name="valueURI"><xsl:value-of
            select="concat($WebApplicationBaseURL,'classifications/SDNB#', ./@ID)" /></xsl:attribute>
          <xsl:attribute name="displayLabel">sdnb</xsl:attribute>
          <xsl:value-of select="./label[@xml:lang='de']/@text" />
        </xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
  