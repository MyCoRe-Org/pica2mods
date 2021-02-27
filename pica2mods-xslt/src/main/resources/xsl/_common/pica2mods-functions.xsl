<?xml version="1.0"?>
<xsl:stylesheet version="3.0" xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:p="info:srw/schema/5/picaXML-v1.0" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:err="http://www.w3.org/2005/xqt-errors"
  exclude-result-prefixes="mods fn xs">

  <xsl:param name="MCR.PICA2MODS.SRU.URL" select="'https://sru.k10plus.de'" />
  <xsl:param name="MCR.PICA2MODS.UNAPI.URL" select="'https://unapi.k10plus.de'" />

  <xsl:function name="pica2mods:queryPicaFromSRUWithQuery" as="element()?">
    <xsl:param name="database" as="xs:string" />
    <xsl:param name="query" as="xs:string" />

    <xsl:variable name="encodedSruQuery" select="encode-for-uri($query)" />
    <xsl:variable name="requestURL"
      select="concat($MCR.PICA2MODS.SRU.URL, '/', $database,'/',
        '?operation=searchRetrieve&amp;maximumRecords=1&amp;recordSchema=picaxml&amp;query=',
        $encodedSruQuery)" />
    <xsl:try>
      <xsl:sequence select="document($requestURL)//p:record" />
      <xsl:catch>
        <xsl:message>
          No result for SRUQuery: <xsl:value-of select="$query" />
          Error code: <xsl:value-of select="$err:code" />
          Reason: <xsl:value-of select="$err:description" />
        </xsl:message>
        <xsl:sequence select="()" />
      </xsl:catch>
    </xsl:try>
  </xsl:function>

  <xsl:function name="pica2mods:queryPicaFromSRUWithPPN" as="element()?">
    <xsl:param name="database" as="xs:string" />
    <xsl:param name="ppn" as="xs:string" />
    <xsl:sequence select="pica2mods:queryPicaFromSRUWithQuery($database, concat('ppn=',$ppn))" />
  </xsl:function>

  <xsl:function name="pica2mods:queryUnAPIForPicaWithPPN" as="element()?">
    <xsl:param name="database" as="xs:string" />
    <xsl:param name="ppn" as="xs:string" />
    <xsl:variable name="requestURL"
      select="concat($MCR.PICA2MODS.UNAPI.URL, '?format=picaxml&amp;id=', $database,':ppn:', $ppn)" />
    <xsl:try>
      <xsl:sequence select="document($requestURL)//p:record" />
      <xsl:catch>
        <xsl:message>
          No result for UnAPIQuery: <xsl:value-of select="fn:concat($database,':ppn:',$ppn)" />
          Error code: <xsl:value-of select="$err:code" />
          Reason: <xsl:value-of select="$err:description" />
        </xsl:message>
        <xsl:sequence select="()" />
      </xsl:catch>
    </xsl:try>
  </xsl:function>

  <xsl:function name="pica2mods:detectPicaMode" as="xs:string">
    <xsl:param name="record" as="element()" />
    <xsl:choose>
      <xsl:when test="$record/p:datafield[@tag='209O']/p:subfield[@code='a' and contains(.,':doctype:epub')]">
        <xsl:value-of select="'EPUB'" />
      </xsl:when>
      <xsl:when test="$record/p:datafield[@tag='007G']/p:subfield[@code='i']/text()='KXP'">
        <xsl:value-of select="'KXP'" />
      </xsl:when>
      <xsl:when
        test="not($record/p:datafield[@tag='011B']) and $record/p:datafield[@tag='010E']/p:subfield[@code='e']/text()='rda'">
        <xsl:value-of select="'RDA'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'KXP'" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  

</xsl:stylesheet>
     