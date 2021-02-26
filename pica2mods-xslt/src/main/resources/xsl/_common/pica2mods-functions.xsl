<?xml version="1.0"?>
<xsl:stylesheet version="3.0" xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:p="info:srw/schema/5/picaXML-v1.0" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="mods fn xs">

  <xsl:param name="MCR.PICA2MODS.SRU.URL" select="'http://sru.k10plus.de'" />
  <xsl:param name="MCR.PICA2MODS.UNAPI.URL" select="'http://unapi.k10plus.de'" />

  <xsl:function name="pica2mods:querySRUForPicaWithQuery" as="element()?">
    <xsl:param name="database" as="xs:string" />
    <xsl:param name="query" as="xs:string" />

    <xsl:variable name="encodedSruQuery" select="encode-for-uri($query)" />
    <xsl:variable name="requestURL"
      select="concat($MCR.PICA2MODS.SRU.URL, '/', $database,'/',
        '?operation=searchRetrieve&amp;maximumRecords=1&amp;recordSchema=picaxml&amp;query=',
        $encodedSruQuery)" />
    <xsl:sequence select="document($requestURL)//p:record" />
  </xsl:function>

  <xsl:function name="pica2mods:querySRUForPicaWithPPN" as="element()?">
    <xsl:param name="database" as="xs:string" />
    <xsl:param name="ppn" as="xs:string" />
    <xsl:sequence select="pica2mods:querySRUForPicaWithQuery($database, concat('ppn=',$ppn))" />
  </xsl:function>

  <xsl:function name="pica2mods:queryUnAPIForPicaWithPPN" as="element()?">
    <xsl:param name="database" as="xs:string" />
    <xsl:param name="ppn" as="xs:string" />
    <xsl:variable name="requestURL"
      select="concat($MCR.PICA2MODS.UNAPI.URL, '?format=picaxml&amp;id=', $database,':ppn:', $ppn)" />
      <xsl:message select="$requestURL" />
    <xsl:sequence select="document($requestURL)//p:record" />
  </xsl:function>

</xsl:stylesheet>
     