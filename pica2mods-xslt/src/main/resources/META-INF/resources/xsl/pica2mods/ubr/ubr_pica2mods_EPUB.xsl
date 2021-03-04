<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="p xalan fn">
  <xsl:import href="cp:ubr/ubr_pica2mods_common.xsl" />
  <xsl:variable name="XSL_VERSION_EPUB" select="concat('ubr_pica2mods_EPUB.xsl from ',$XSL_VERSION_PICA2MODS)" />
  <xsl:template match="/p:record" mode="EPUB">

    <mods:originInfo eventType="publication"> <!-- 4030 033A -->
      <xsl:if test="./p:datafield[@tag='033A']/p:subfield[@code='n']">  <!-- 4030 Ort, Verlag -->
        <mods:publisher>
          <xsl:value-of select="./p:datafield[@tag='033A']/p:subfield[@code='n']" />
        </mods:publisher>
      </xsl:if>
      <xsl:if test="./p:datafield[@tag='033A']/p:subfield[@code='p']">  <!-- 4030 Ort, Verlag -->
        <mods:place>
          <mods:placeTerm type="text">
            <xsl:value-of select="./p:datafield[@tag='033A']/p:subfield[@code='p']" />
          </mods:placeTerm>
        </mods:place>
      </xsl:if>

      <xsl:for-each select="./p:datafield[@tag='032@']"> <!-- 4020 Ausgabe -->
        <xsl:choose>
          <xsl:when test="./p:subfield[@code='c']">
            <mods:edition>
              <xsl:value-of select="./p:subfield[@code='a']" />
              /
              <xsl:value-of select="./p:subfield[@code='c']" />
            </mods:edition>
          </xsl:when>
          <xsl:otherwise>
            <mods:edition>
              <xsl:value-of select="./p:subfield[@code='a']" />
            </mods:edition>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>

      <xsl:for-each select="./p:datafield[@tag='011@']">   <!-- 1100 -->
        <xsl:choose>
            <xsl:when test="./p:subfield[@code='b']">
              <mods:dateIssued keyDate="yes" encoding="iso8601" point="start">
                <xsl:value-of select="./p:subfield[@code='a']" />
              </mods:dateIssued>
              <mods:dateIssued encoding="iso8601" point="end">
                <xsl:value-of select="./p:subfield[@code='b']" />
              </mods:dateIssued>
            </xsl:when>
          <xsl:otherwise>
            <mods:dateIssued keyDate="yes" encoding="iso8601">
              <xsl:if test="substring(../p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)='b' or substring(../p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)='d'">
                <xsl:attribute name="point">start</xsl:attribute>
              </xsl:if>
              <xsl:value-of select="./p:subfield[@code='a']" />
            </mods:dateIssued>
          </xsl:otherwise>
        </xsl:choose>
         <xsl:if test="./p:subfield[@code='n']">
            <mods:dateIssued qualifier="approximate">
              <xsl:value-of select="./p:subfield[@code='n']" />
            </mods:dateIssued>
        </xsl:if>
      </xsl:for-each>
      
      <xsl:if test="./p:datafield[@tag='037C']/p:subfield[@code='f']">  <!-- 4204 Hochschulschriftenvermerk, Jahr der Verteidigung -->
        <mods:dateOther type="defence" encoding="iso8601">
          <xsl:value-of select="./p:datafield[@tag='037C']/p:subfield[@code='f']" />
        </mods:dateOther>
      </xsl:if>

      <xsl:for-each select="./p:datafield[@tag='002@']">
        <xsl:choose>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='a'">
            <mods:issuance>monographic</mods:issuance>
          </xsl:when>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='b'">
            <mods:issuance>serial</mods:issuance>
          </xsl:when>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='c'">
            <mods:issuance>multipart monograph</mods:issuance>
          </xsl:when>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='d'">
            <mods:issuance>serial</mods:issuance>
          </xsl:when>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='f'">
            <mods:issuance>monographic</mods:issuance>
          </xsl:when>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='F'">
            <mods:issuance>monographic</mods:issuance>
          </xsl:when>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='j'">
            <mods:issuance>single unit</mods:issuance>
          </xsl:when>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='s'">
            <mods:issuance>single unit</mods:issuance>
          </xsl:when>
          <xsl:when test="substring(./p:subfield[@code='0'],2,1)='v'">
            <mods:issuance>monographic</mods:issuance>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </mods:originInfo>
    <xsl:if test="./p:datafield[@tag='033E']">
      <mods:originInfo eventType="online_publication"> <!-- 4034 -->
        <xsl:if test="./p:datafield[@tag='033E']/p:subfield[@code='n']">  <!-- 4034 $n Verlag -->
          <mods:publisher>
            <xsl:value-of select="./p:datafield[@tag='033E']/p:subfield[@code='n']" />
          </mods:publisher>
        </xsl:if>
        <xsl:if test="./p:datafield[@tag='033E']/p:subfield[@code='p']">  <!-- 4034 $p Ort -->
          <mods:place>
            <mods:placeTerm type="text">
              <xsl:value-of select="./p:datafield[@tag='033E']/p:subfield[@code='p']" />
            </mods:placeTerm>
          </mods:place>
        </xsl:if>
        <xsl:if test="./p:datafield[@tag='033E']/p:subfield[@code='h']">  <!-- 4034 $h Jahr -->
          <mods:dateCaptured encoding="iso8601">
            <xsl:value-of select="./p:datafield[@tag='033E']/p:subfield[@code='h']" />
          </mods:dateCaptured>
        </xsl:if>
      </mods:originInfo>
    </xsl:if>

    <xsl:for-each select="./p:datafield[@tag='017C' and contains(./p:subfield[@code='u'], 'rosdok')][1]">
      <mods:location>
        <mods:physicalLocation type="online" authorityURI="http://d-nb.info/gnd/" valueURI="http://d-nb.info/gnd/25968-8">Universitätsbibliothek Rostock</mods:physicalLocation>
        <mods:url usage="primary" access="object in context">
          <xsl:value-of select="./p:subfield[@code='u']" />
        </mods:url>
      </mods:location>
    </xsl:for-each>
    <xsl:for-each select="./p:datafield[@tag='017C' and contains(./p:subfield[@code='u'], 'digibib.hs-nb.de/resolve/id')][1]">
      <mods:location>
        <mods:physicalLocation type="online" authorityURI="http://d-nb.info/gnd/" valueURI="http://d-nb.info/gnd/1162078316">Hochschulbibliothek Neubrandenburg</mods:physicalLocation>
        <mods:url usage="primary" access="object in context">
          <xsl:value-of select="./p:subfield[@code='u']" />
        </mods:url>
      </mods:location>
    </xsl:for-each>
    
    <xsl:for-each select="./p:datafield[@tag='034D']/p:subfield[@code='a' and contains(., 'Seite')]">
      <mods:physicalDescription>
        <mods:extent unit="pages"><xsl:value-of select="normalize-space(substring-before(substring-after(.,'('),'Seite'))" /></mods:extent>
      </mods:physicalDescription>
    </xsl:for-each>
    
   
    

    <xsl:for-each select="./p:datafield[@tag='037A']"><!-- Gutachter in Anmerkungen -->
      <xsl:choose>
        <xsl:when test="starts-with(./p:subfield[@code='a'], 'GutachterInnen:')">
            <mods:note type="referee">
              <xsl:value-of select="substring-after(./p:subfield[@code='a'], 'GutachterInnen: ')" />
            </mods:note>
        </xsl:when>
        <xsl:otherwise>
            <mods:note type="other">
              <xsl:value-of select="./p:subfield[@code='a']" />
            </mods:note>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='037B' or @tag='046L' or @tag='046F' or @tag='046G' or @tag='046H' or @tag='046I']"><!-- 4201, 4202, 4221, 4215, 4216, 4217, 4218 RDA raus 4202, 4215, 4216 neu 4210, 4212, 4221, 4223, 4226 (einfach den ganzen Anmerkungskrams mitnehmen" -->
      <mods:note type="other">
        <xsl:value-of select="./p:subfield[@code='a']" />
      </mods:note>
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='047C' or @tag='022A']">
      <!-- 4200 (047C, abweichende Sucheinstiege, RDA zusätzlich:3210 (022A, Werktitel) und 3260 (027A, abweichender Titel) -->
      <mods:note type="titlewordindex">
        <xsl:value-of select="./p:subfield[@code='a']" />
      </mods:note>
    </xsl:for-each>

  </xsl:template>

</xsl:stylesheet> 