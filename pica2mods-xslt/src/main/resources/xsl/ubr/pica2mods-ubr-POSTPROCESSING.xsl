<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
                 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
                 xmlns:p="info:srw/schema/5/picaXML-v1.0"
                 xmlns:mods="http://www.loc.gov/mods/v3"
                 xmlns:xlink="http://www.w3.org/1999/xlink"
                 xmlns:json="http://www.w3.org/2005/xpath-functions"
                 exclude-result-prefixes="mods pica2mods"
                 expand-text="yes">

  <!-- add a default dateIssued for display (without @encoding attribute) -->
  <xsl:template match=".[mods:dateIssued[@encoding] and not(mods:dateIssued[not(@encoding)])]"
    mode="ubrPostProcessing">
    <xsl:copy>
      <xsl:copy-of select="*|@*|processing-instruction()|comment()" />
      <xsl:comment>
        <xsl:text>UBR-Post-Processing:</xsl:text>
      </xsl:comment>
      <mods:dateIssued>
        <xsl:choose>
          <xsl:when
            test="mods:dateIssued[@encoding and @point='start'] and mods:dateIssued[@encoding and @point='end']">
            <xsl:value-of
              select="concat(mods:dateIssued[@encoding and @point='start'],'-',mods:dateIssued[@encoding and @point='end'])" />
          </xsl:when>
          <xsl:when test="mods:dateIssued[@encoding and @point='start']">
            <xsl:value-of select="concat(mods:dateIssued[@encoding and @point='start'],'-')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="mods:dateIssued[@encoding]" />
          </xsl:otherwise>
        </xsl:choose>
      </mods:dateIssued>
    </xsl:copy>
  </xsl:template>

  <!-- add a default dateCaptured for display (without @encoding attribute) -->
  <xsl:template match=".[mods:dateCaptured[@encoding] and not(mods:dateCaptured[not(@encoding)])]"
    mode="ubrPostProcessing">
    <xsl:copy>
      <xsl:copy-of select="*|@*|processing-instruction()|comment()" />
      <xsl:comment>
        <xsl:text>UBR-Post-Processing:</xsl:text>
      </xsl:comment>
      <mods:dateCaptured>
        <xsl:choose>
          <xsl:when
            test="mods:dateCaptured[@encoding and @point='start'] and mods:dateCaptured[@encoding and @point='end']">
            <xsl:value-of
              select="concat(mods:dateCaptured[@encoding and @point='start'],'-',mods:dateCaptured[@encoding and @point='end'])" />
          </xsl:when>
          <xsl:when test="mods:dateCaptured[@encoding and @point='start']">
            <xsl:value-of select="concat(mods:dateCaptured[@encoding and @point='start'],'-')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="mods:dateCaptured[@encoding]" />
          </xsl:otherwise>
        </xsl:choose>
      </mods:dateCaptured>
    </xsl:copy>
  </xsl:template>

  <!-- delete all urls which look like our purls / do nothing -->
  <xsl:template match="mods:identifier[@type='url' and text()= ./../mods:identifier[@type='purl']/text()]"
    mode="ubrPostProcessing" />

  <xsl:template match="*|@*|processing-instruction()|comment()" mode="ubrPostProcessing">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"
        mode="ubrPostProcessing" />
    </xsl:copy>
  </xsl:template>

  <!-- Expand personal details -->
  <xsl:template match="mods:mods" mode="ubrPostProcessing">
    <xsl:variable name="personal_details" select="json-to-xml(mods:note[@type='personal_details'])" />
    <mods:mods>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"
        mode="ubrPostProcessing">
        <xsl:with-param name="personal_details" select="$personal_details" />
      </xsl:apply-templates>
      <xsl:if test="$personal_details/*">
        <xsl:comment>Temporär zu Demonstrationszwecken und Debugging ...</xsl:comment>
        <mods:extension displayLabel="person_details">
          <xsl:copy-of select="$personal_details" />
        </mods:extension>
      </xsl:if>
    </mods:mods>
  </xsl:template>

  <xsl:template match="mods:name" mode="ubrPostProcessing">
    <xsl:param name="personal_details" />
    <xsl:variable name="mods_name" select="." />
    <mods:name>
      <xsl:copy-of select="*|@*|processing-instruction()|comment()" />
      <xsl:variable name="key"
        select="concat($mods_name/mods:namePart[@type='family'], ', ',$mods_name/mods:namePart[@type='given'])" />
      <xsl:if test="$personal_details/*">
        <xsl:comment>
          <xsl:value-of select="concat('Key: ', $key)" />
        </xsl:comment>
      </xsl:if>
      <xsl:for-each select="$personal_details/json:map/json:map[@key=$key]">
        <xsl:if
          test="./json:string[@key='orcid']  and not(./json:string[@key='orcid'] = $mods_name/mods:nameIdentifier[@type='orcid'])">
          <mods:nameIdentifier type="orcid">
            <xsl:value-of select="./json:string[@key='orcid']" />
          </mods:nameIdentifier>
        </xsl:if>
        <xsl:if
          test="./json:string[@key='gnd']  and not(./json:string[@key='gnd'] = $mods_name/mods:nameIdentifier[@type='gnd'])">
          <mods:nameIdentifier type="gnd">
            <xsl:value-of select="./json:string[@key='gnd']" />
          </mods:nameIdentifier>
        </xsl:if>
        <xsl:if
          test="./json:string[@key='affil']  and not(./json:string[@key='affil'] = $mods_name/mods:affiliation)">
          <mods:affiliation>
            <xsl:value-of select="./json:string[@key='affil']" />
          </mods:affiliation>
        </xsl:if>
        <xsl:if
          test="./json:string[@key='affil2']  and not(./json:string[@key='affil2'] = $mods_name/mods:affiliation)">
          <mods:affiliation>
            <xsl:value-of select="./json:string[@key='affil2']" />
          </mods:affiliation>
        </xsl:if>
      </xsl:for-each>
    </mods:name>
  </xsl:template>
  
</xsl:stylesheet>
