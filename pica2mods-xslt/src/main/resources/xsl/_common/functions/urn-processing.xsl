<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
  xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" 
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:err="http://www.w3.org/2005/xqt-errors"
  exclude-result-prefixes="fn xs err map pica2mods">

  <xsl:function name="pica2mods:createChecksumForURNBase" as="xs:short">
    <xsl:param name="urnBase" as="xs:string" />
    <!-- Algorithmus: https://web.archive.org/web/20200214004623/http://www.persistent-identifier.de/?link=316 -->
    <xsl:variable name="charmap"
      select="map{'0': 1, '1': 2, '2': 3, '3': 4, '4': 5, '5': 6, '6': 7, '7': 8, '8': 9, '9':41,
                  'A':18, 'B':14, 'C':19, 'D':15, 'E':16, 'F':21, 'G':22, 'H':23, 'I':24, 'J':25,
                  'K':42, 'L':26, 'M':27, 'N':13, 'O':28, 'P':29, 'Q':31, 'R':12, 'S':32, 'T':33,
                  'U':11, 'V':34, 'W':35, 'X':36, 'Y':37, 'Z':38, 
                  '+':49, '.':47, ':':17, '-':39, '_':43, '/':45}" />
    
    <!-- Zunächst wird der URN-String in eine Ziffernfolge konvertiert, bei der jedem Element der URN ein Zahlenwert zugewiesen wird. 
         Die entsprechenden Ziffern gehen aus der Konkordanztabelle hervor. -->
    <xsl:variable name="values" as="xs:integer*">
      <xsl:for-each select="1 to string-length($urnBase)">
       <xsl:sequence select="map:get($charmap, upper-case(substring($urnBase, ., 1))) "/>
      </xsl:for-each>    
    </xsl:variable>
    <xsl:variable name="ziffernfolge" select="string-join($values)" />
    
    <!-- Jede Zahl der Ziffernfolge wird einzeln von links nach rechts aufsteigend, beginnend mit 1 multipliziert,
         anschließend wird die Summe gebildet.  -->
    <xsl:variable name="products" as="xs:integer*">
      <xsl:for-each select="1 to string-length($ziffernfolge)">
        <xsl:sequence select="xs:integer(. * number(substring($ziffernfolge, ., 1)))"/>
      </xsl:for-each>    
    </xsl:variable>
    <!-- Diese Produktsumme wird durch die letzte Zahl der URN-Ziffernfolge dividiert. -->
    <xsl:variable name="quotient" select="sum($products) div number(substring($ziffernfolge, string-length($ziffernfolge), 1))"/>
    <!-- Die letzte Zahl vor dem Komma des Quotienten ist die Prüfziffer. -->
    <xsl:sequence select="xs:short(floor($quotient) mod 10)" />
  </xsl:function>
  
  <xsl:function name="pica2mods:createURNWithChecksumForURNBase" as="xs:string">
    <xsl:param name="urnBase" as="xs:string" />
    <xsl:sequence select="concat($urnBase, pica2mods:createChecksumForURNBase($urnBase))" />
  </xsl:function>
    
  <xsl:function name="pica2mods:validateURN" as="xs:boolean">
    <xsl:param name="urn" as="xs:string" />
    <xsl:sequence select="pica2mods:createChecksumForURNBase(substring($urn, 1, string-length($urn)- 1)) = number(substring($urn, string-length($urn), 1))" />
  </xsl:function>
</xsl:stylesheet>
