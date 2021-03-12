 <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
  xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" version="3.0"
  xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions" exclude-result-prefixes="mods pica2mods"
  expand-text="yes">

  <!-- add a default dateIssued for display (without @encoding attribute) -->
  <xsl:template match=".[mods:dateIssued[@encoding] and not(mods:dateIssued[not(@encoding)])]"
    mode="ubrPostProcessing">
    <xsl:copy>
      <xsl:copy-of select="*|@*|processing-instruction()|comment()" />
      <xsl:comment>
        UBR-Post-Processing:
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
        UBR-Post-Processing:
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
  
</xsl:stylesheet>
