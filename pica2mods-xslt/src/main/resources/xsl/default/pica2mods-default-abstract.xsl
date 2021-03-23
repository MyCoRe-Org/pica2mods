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
      <xsl:call-template name="modsAbstract" />
    </mods:mods>
  </xsl:template>

  <!-- Diskussion:
       RS 27.02.21:
       Das Feld erlaubt neuerdings für nichtlateinische Sprachen das Unterfeld $L für Sprache nach ISO-639-2b
       Können / Wollen wir dort "kreativ" auch unsere Sprachcodes ger, eng, fra, spa, codieren?
  
       Alternativ würde ich eine kleine Sprachheuristik für Deutsch und Englisch (häufigste Worte) implementieren.
       Wenn das Ergebnis eindeutig ist, könnte die Sprache gesetzt werden. 
       Sonst könnte "mis" gesetzt werden, damit die Datensätze suchbar sind und gelegentlich manuell korrigiert werden können. 
   -->

  <xsl:template name="modsAbstract">
    <!-- 4207 inhaltliche Zusammenfassung -->
    <!--mods:abstract aus 047I mappen und lang-Attribut aus spitzen Klammern am Ende -->
    <xsl:for-each select="./p:datafield[@tag='047I']/p:subfield[@code='a']">
      <mods:abstract type="summary">
        <xsl:choose>
          <xsl:when test="ends-with(.,'&lt;ger&gt;')">
            <xsl:attribute name="xml:lang">de</xsl:attribute>
            <xsl:value-of select="normalize-space(substring(., 1, string-length(.)-5))" />
          </xsl:when>
          <xsl:when test="ends-with(.,'&lt;eng&gt;')">
            <xsl:attribute name="xml:lang">en</xsl:attribute>
            <xsl:value-of select="normalize-space(substring(., 1, string-length(.)-5))" />
          </xsl:when>
          <xsl:when test="ends-with(.,'&lt;spa&gt;')">
            <xsl:attribute name="xml:lang">es</xsl:attribute>
            <xsl:value-of select="normalize-space(substring(., 1, string-length(.)-5))" />
          </xsl:when>
          <xsl:when test="ends-with(.,'&lt;fra&gt;')">
            <xsl:attribute name="xml:lang">fr</xsl:attribute>
            <xsl:value-of select="normalize-space(substring(., 1, string-length(.)-5))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="lang" select="pica2mods:detectLanguage(.)" />
            <xsl:if test="$lang">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$lang" /></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="." />
          </xsl:otherwise>
        </xsl:choose>
      </mods:abstract>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
