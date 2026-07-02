<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:p="info:srw/schema/5/picaXML-v1.0" expand-text="yes">

  <xsl:template match="p:record">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"
        mode="picaPreProcessing" />
    </xsl:copy>
  </xsl:template>

  <xsl:template name="removeMultilang">
    <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"
      mode="picaPreProcessing" />
  </xsl:template>

  <!-- remove multi language datafields -->
  <xsl:template match="p:datafield[p:subfield[@code='T']]" mode="picaPreProcessing">
    <!-- Das entsprechende Datafield für die Sprache Ltn oder wenn es kein Datafield in Latn gibt, das jeweils erste datafield 
      <xsl:variable name="this" select="." /> <xsl:if test="p:subfield[@code='U']='Latn' or (count(../p:datafield[@tag=$this/@tag][p:subfield[@code='T'] 
      = $this/p:subfield[@code='T']][p:subfield[@code='U']='Latn'])=0 and . = ../p:datafield[@tag=$this/@tag][p:subfield[@code='T'] 
      = $this/p:subfield[@code='T']][1])"> -->
    <!-- Da ein Eintrag in Latn pflicht zu sein scheint, geht es kürzer: -->
    <xsl:if test="p:subfield[@code='U']='Latn'">
      <xsl:copy>
        <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"
          mode="picaPreProcessing" />
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*|@*|processing-instruction()|comment()" mode="picaPreProcessing">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"
        mode="picaPreProcessing" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

