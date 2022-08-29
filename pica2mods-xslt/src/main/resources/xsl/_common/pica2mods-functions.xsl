<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
  xmlns:p="info:srw/schema/5/picaXML-v1.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:err="http://www.w3.org/2005/xqt-errors"
  exclude-result-prefixes="mods fn xs err">

  <xsl:import href="_common/functions/detect-language.xsl" />
  <xsl:import href="_common/functions/urn-processing.xsl" />

  <xsl:param name="MCR.PICA2MODS.SRU.URL" select="'https://sru.k10plus.de'" />
  <xsl:param name="MCR.PICA2MODS.UNAPI.URL" select="'https://unapi.k10plus.de'" />
  <xsl:param name="MCR.PICA2MODS.DATABASE" select="'k10plus'" />

  <xsl:function name="pica2mods:queryPicaFromSRUWithQuery" as="element()?">
    <xsl:param name="database" as="xs:string" />
    <xsl:param name="query" as="xs:string" />

    <xsl:variable name="encodedSruQuery" select="encode-for-uri($query)" />
    <xsl:variable name="requestURL"
      select="concat($MCR.PICA2MODS.SRU.URL, '/', $database,
        '?operation=searchRetrieve&amp;maximumRecords=1&amp;recordSchema=picaxml&amp;query=',
        $encodedSruQuery)" />
    <xsl:try>
      <xsl:variable name="picaWithoutLang">
        <xsl:apply-templates select="document($requestURL)//p:record" mode="picaPreProcessing" />
      </xsl:variable>
      <xsl:sequence select="$picaWithoutLang//p:record" />
      <xsl:catch>
        <xsl:message>
          No result for SRUQuery:
          <xsl:value-of select="$query" />
          Error code:
          <xsl:value-of select="$err:code" />
          Reason:
          <xsl:value-of select="$err:description" />
        </xsl:message>
        <xsl:sequence select="()" />
      </xsl:catch>
    </xsl:try>
  </xsl:function>

  <xsl:function name="pica2mods:queryPicaFromSRUWithPPN" as="element()?">
    <xsl:param name="database" as="xs:string" />
    <xsl:param name="ppn" as="xs:string" />

    <xsl:if test="contains($ppn, 'x')">
      <xsl:message>
        PPN {$ppn} ends with small 'x' Please fix it!
      </xsl:message>
    </xsl:if>
    <xsl:sequence select="pica2mods:queryPicaFromSRUWithQuery($database, concat('ppn=', upper-case($ppn)))" />
  </xsl:function>

  <xsl:function name="pica2mods:queryPicaFromUnAPIWithPPN" as="element()?">
    <xsl:param name="database" as="xs:string" />
    <xsl:param name="ppn" as="xs:string?" />
    <xsl:choose>
      <xsl:when test="$ppn">
        <xsl:if test="contains($ppn, 'x')">
          <xsl:message>
            PPN {$ppn} ends with small 'x' Please fix it!
          </xsl:message>
        </xsl:if>
        <xsl:variable name="requestURL"
          select="concat($MCR.PICA2MODS.UNAPI.URL, '?format=picaxml&amp;id=', $database,':ppn:', upper-case($ppn))" />
        <xsl:try>
          <xsl:variable name="picaWithoutLang">
              <xsl:apply-templates select="document($requestURL)//p:record" mode="picaPreProcessing" />
          </xsl:variable>
          <xsl:sequence select="$picaWithoutLang//p:record" />
          <xsl:catch>
            <xsl:message>
              No result for UnAPIQuery:
              <xsl:value-of select="fn:concat($database,':ppn:',$ppn)" />
              Error code:
              <xsl:value-of select="$err:code" />
              Reason:
              <xsl:value-of select="$err:description" />
            </xsl:message>
            <xsl:sequence select="()" />
          </xsl:catch>
        </xsl:try>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="pica2mods:queryPicaDruck" as="element()?">
    <xsl:param name="current" as="element()" />
    <xsl:choose>
      <!-- wenn keine O-Aufnahme - Rückgabe der Eingabe -->
      <xsl:when test="not(starts-with($current/p:datafield[@tag='002@']/p:subfield[@code='0'],'O'))">
        <xsl:sequence select="$current" />
      </xsl:when>
      <!-- 4256 Beziehungen zur Reproduktion in anderer physischer Form -->
      <!-- Verknüpfung über PPN -->
      <xsl:when test="$current/p:datafield[@tag='039I']/p:subfield[@code='9']">
        <xsl:variable name="ppnA"
          select="$current/p:datafield[@tag='039I'][1]/p:subfield[@code='9']/text()" />
        <xsl:sequence select="pica2mods:queryPicaFromSRUWithQuery($MCR.PICA2MODS.DATABASE, concat('pica.ppn=', $ppnA))" />
      </xsl:when>
      <!-- Verknüpfung über ZDB-ID -->
      <xsl:when test="$current/p:datafield[@tag='039I']/p:subfield[@code='C' and text()='ZDB']">
        <xsl:variable name="zdbA"
          select="$current/p:datafield[@tag='039I'][1]/p:subfield[@code='C' and text()='ZDB']/following-sibling::p:subfield[@code='6'][1]/text()" />
        <xsl:sequence select="pica2mods:queryPicaFromSRUWithQuery($MCR.PICA2MODS.DATABASE, concat('pica.zdb=', $zdbA))" />
      </xsl:when>
      <!-- Fallback: leere Sequence -->
      <xsl:otherwise>
        <xsl:sequence select="()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="pica2mods:detectMode" as="xs:string">
    <xsl:param name="record" as="element()" />
    <xsl:choose>
      <xsl:when
        test="$record/p:datafield[@tag='011B']/p:subfield[@code='a'] or $record/p:datafield[@tag='011@']/p:subfield[@code='r'] or $record/p:datafield[@tag='039I']/p:subfield[@code='i' and text()='Elektronische Reproduktion von']">
        <xsl:value-of select="'REPRO'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'DEFAULT'" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="pica2mods:sortableSortstring" as="xs:string">
    <xsl:param name="input" as="xs:string" />
    <xsl:variable name="output">
      <!-- Trenne die Zeichenkette an Punkt oder Komma -->
      <xsl:for-each select="tokenize($input, '\.|,')">
        <!-- normiere den Teilstring (Kleinbuchstaben, ohne Klammern) -->
        <xsl:variable name="normal" select="translate(lower-case(.),'()[]{}','')" />
        <!-- wenn der String mit einer Zahl beginnt (oder eine Zahl ist) wird die Zahl 4-stellig ausgegeben, der Rest ignoriert -->
        <xsl:analyze-string regex="^(\d+).*$" select="$normal">
          <xsl:matching-substring>
            <part>
              <xsl:value-of
                select="concat(string-join(for $i in (string-length(regex-group(1))+1 to 4) return '0') , regex-group(1))" />
            </part>
          </xsl:matching-substring>
          <!-- alle anderen Werte werden als String übernommen und mit '_' auf 12 Stellen aufgefüllt -->
          <xsl:non-matching-substring>
            <part>
              <xsl:value-of
                select="concat($normal, string-join(for $i in (string-length($normal)+1 to 12) return '_'))" />
            </part>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="string-join($output/part, '-')" />
  </xsl:function>
  
</xsl:stylesheet>
