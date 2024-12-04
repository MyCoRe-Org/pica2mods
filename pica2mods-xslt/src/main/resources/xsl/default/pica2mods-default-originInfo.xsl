<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions" 
                xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="mods pica2mods p xlink">

  <xsl:import use-when="system-property('XSL_TESTING')='true'" href="_common/pica2mods-functions.xsl" />
  
  <xsl:param name="MCR.PICA2MODS.DATABASE" select="'k10plus'" />
  
  <!-- This template is for testing purposes -->
  <xsl:template match="p:record">
    <mods:mods>
      <xsl:call-template name="modsOriginInfo" />
    </mods:mods>
  </xsl:template>

  <xsl:template name="modsOriginInfo">
    <xsl:variable name="picaMode" select="pica2mods:detectMode(.)" />

      <mods:originInfo>
        <xsl:choose>
          <xsl:when test="./p:datafield[@tag='033F']">
            <xsl:attribute name="eventType">production</xsl:attribute>
            <xsl:call-template name="common_date_created"> <!-- 1100 der A-Aufnahme -->
              <xsl:with-param name="datafield" select="./p:datafield[@tag='011@']" />
            </xsl:call-template> 
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="eventType">publication</xsl:attribute>
            <xsl:call-template name="common_date_issued"> <!-- 1100 der A-Aufnahme -->
              <xsl:with-param name="datafield" select="./p:datafield[@tag='011@']" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="./p:datafield[@tag='033F' or @tag='033A']">
          <xsl:call-template name="common_publisher_name_place_with_university_place_expansion"> <!-- 4046 / 4030 -->
            <xsl:with-param name="datafield" select="." />
          </xsl:call-template>
        </xsl:for-each>
        <xsl:call-template name="common_norm_place"> <!-- 4040 / 033D -->
          <xsl:with-param name="record" select="." />
        </xsl:call-template>
        <xsl:call-template name="common_edition">
          <xsl:with-param name="record" select="." />
        </xsl:call-template>
        <xsl:call-template name="common_issuance">
          <xsl:with-param name="record" select="." />
        </xsl:call-template>

        <!-- PPN 1726228770 an 2 Hochschulen eingereicht -->
        <xsl:if test="./p:datafield[@tag='037C']/p:subfield[@code='f']">  <!-- 4204 Hochschulschriftenvermerk, Jahr der Verteidigung -->
          <mods:dateOther type="defence" encoding="w3cdtf">
            <xsl:value-of select="./p:datafield[@tag='037C'][1]/p:subfield[@code='f']" />
          </mods:dateOther>
        </xsl:if>
      </mods:originInfo>

    <xsl:if test="$picaMode = 'REPRO'"> 
        <mods:originInfo eventType="digitization">
          <xsl:choose>
            <xsl:when test="./p:datafield[@tag='011B'] and not(./p:datafield[tag='037J']/p:subfield[@code='d'])"> <!-- 1109, not(4238) -->
              <xsl:call-template name="common_date_captured">
                <xsl:with-param name="datafield" select="./p:datafield[@tag='011B']" />
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="./p:datafield[tag='037J']/p:subfield[@code='d']"> <!-- 4238 -->
              <mods:dateCaptured keyDate="yes">
                <xsl:value-of select="$datafield/p:subfield[@code='d']" />
              </mods:dateCaptured>
            </xsl:when>
            <xsl:otherwise> <!-- 1100 / 011@ -->
              <xsl:call-template name="common_date_captured">
                <xsl:with-param name="datafield" select="./p:datafield[@tag='011@']" />
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="./p:datafield[@tag='037J']/p:subfield[@code='b' or @code='c']"> <!-- 4038 -->
              <xsl:for-each select="./p:datafield[@tag='037J']">
                <xsl:call-template name="common_publisher_name_place_with_university_place_expansion">
                  <xsl:with-param name="datafield" select="." />
                </xsl:call-template>
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="./p:datafield[@tag='033N']"> <!-- 4048 -->
              <xsl:for-each select="./p:datafield[@tag='033N']">
                <xsl:call-template name="common_publisher_name_place_with_university_place_expansion">
                  <xsl:with-param name="datafield" select="." />
                </xsl:call-template>
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="./p:datafield[@tag='033B']"> <!-- 4031 (nicht RDA) -->
              <xsl:for-each select="./p:datafield[@tag='033B']">
                <xsl:call-template name="common_publisher_name_place_with_university_place_expansion">
                  <xsl:with-param name="datafield" select="." />
                </xsl:call-template>
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="./p:datafield[@tag='033P']"> <!-- 4067 (nicht RDA) -->
              <xsl:for-each select="./p:datafield[@tag='033P']">
                <xsl:call-template name="common_publisher_name_place_with_university_place_expansion">
                  <xsl:with-param name="datafield" select="." />
                </xsl:call-template>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise> <!-- 4030 / 033A -->
              <xsl:for-each select="./p:datafield[@tag='033A']">
                <xsl:call-template name="common_publisher_name_place_with_university_place_expansion">
                  <xsl:with-param name="datafield" select="." />
                </xsl:call-template>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </mods:originInfo>
        </xsl:if>

        <xsl:if test="./p:datafield[@tag='033E']"> <!-- 4034 -->
          <mods:originInfo eventType="upload">
            <xsl:if test="./p:datafield[@tag='033E']/p:subfield[@code='h']">  <!-- 4034 $h Jahr -->
              <mods:dateCaptured encoding="w3cdtf">
                <xsl:value-of select="./p:datafield[@tag='033E']/p:subfield[@code='h']" />
              </mods:dateCaptured>
            </xsl:if>
            <xsl:call-template name="common_publisher_name_place_with_university_place_expansion">
              <xsl:with-param name="datafield" select="./p:datafield[@tag='033E']" />
            </xsl:call-template>
          </mods:originInfo>
        </xsl:if>
  </xsl:template>

  <xsl:template name="common_publisher_name_place_with_university_place_expansion">
    <xsl:param name="datafield" />
    <xsl:choose>
      <!-- Wenn es einen Namen gibt und dieser mit Universität, Universitätsbibliothek beginnt und es einen oder mehrere 
        Ortsnamen gibt, die nicht im Namen der Institution enthalten sind, dann ergänze den Ortsnamen hinter den Insitutionsnamen 
        Beachte: ($sequence = $item) prüft, ob das Item bestandteil der Liste ist -->
      <xsl:when
        test="$datafield/@tag='037J' and $datafield/p:subfield[@code='c' 
                 and (tokenize('universität,universitätsbibliothek,hochschule,hochschulbibliothek,universitätsverlag,stadtarchiv',',') = tokenize(lower-case(.),' ')[1]) 
                 and $datafield/p:subfield[@code='b' and not(contains($datafield/p:subfield[@code='c'][1], . ))]] ">
        <mods:publisher>
          <xsl:value-of
            select="concat($datafield/p:subfield[@code='c'][1], ' ', $datafield/p:subfield[@code='b'][1])" />
        </mods:publisher>
      </xsl:when>
      <xsl:when
        test="$datafield/@tag='037J' and $datafield/p:subfield[@code='c' 
                 and (tokenize('university,library',',') = tokenize(lower-case(.),' ')[1]) 
                 and $datafield/p:subfield[@code='b' and not(contains($datafield/p:subfield[@code='c'][1], . ))]] ">
        <mods:publisher>
          <xsl:value-of
            select="concat($datafield/p:subfield[@code='c'][1], ' of ', $datafield/p:subfield[@code='b'][1])" />
        </mods:publisher>
      </xsl:when>
      <xsl:when test="$datafield/@tag='037J' and $datafield/p:subfield[@code='c']">
        <xsl:for-each select="$datafield/p:subfield[@code='c']">
          <mods:publisher>
            <xsl:value-of select="." />
          </mods:publisher>
        </xsl:for-each>
      </xsl:when>
      <xsl:when
        test="$datafield/p:subfield[@code='n' 
                 and (tokenize('universität,universitätsbibliothek,hochschule,hochschulbibliothek,universitätsverlag,stadtarchiv',',') = tokenize(lower-case(.),' ')[1]) 
                 and $datafield/p:subfield[@code='p' and not(contains($datafield/p:subfield[@code='n'][1], . ))]] ">
        <mods:publisher>
          <xsl:value-of
            select="concat($datafield/p:subfield[@code='n'][1], ' ', $datafield/p:subfield[@code='p'][1])" />
        </mods:publisher>
      </xsl:when>
      <xsl:when
        test="$datafield/p:subfield[@code='n' 
                 and (tokenize('university,library',',') = tokenize(lower-case(.),' ')[1]) 
                 and $datafield/p:subfield[@code='p' and not(contains($datafield/p:subfield[@code='n'][1], . ))]] ">
        <mods:publisher>
          <xsl:value-of
            select="concat($datafield/p:subfield[@code='n'][1], ' of ', $datafield/p:subfield[@code='p'][1])" />
        </mods:publisher>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$datafield/p:subfield[@code='n']">
          <mods:publisher>
            <xsl:value-of select="." />
          </mods:publisher>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    
    <xsl:choose>
      <xsl:when test="$datafield/@tag='037J' and $datafield/p:subfield[@code='b']">
        <xsl:for-each select="$datafield/p:subfield[@code='b']">
          <mods:place>
            <mods:placeTerm type="text">
              <xsl:value-of select="." />
            </mods:placeTerm>
          </mods:place>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$datafield/p:subfield[@code='p']">
          <mods:place>
            <mods:placeTerm type="text">
              <xsl:value-of select="." />
            </mods:placeTerm>
          </mods:place>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="common_issuance">
    <xsl:param name="record" />
    <xsl:variable name="pica0500_2" select="substring($record/p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
    <xsl:choose>
      <xsl:when test="$pica0500_2='a'">
        <mods:issuance>monographic</mods:issuance>
      </xsl:when>
      <xsl:when test="$pica0500_2='b'">
        <mods:issuance>serial</mods:issuance>
      </xsl:when>
      <xsl:when test="$pica0500_2='c'">
        <mods:issuance>multipart monograph</mods:issuance>
      </xsl:when>
      <xsl:when test="$pica0500_2='d'">
        <mods:issuance>serial</mods:issuance>
      </xsl:when>
      <xsl:when test="$pica0500_2='f'">
        <mods:issuance>monographic</mods:issuance>
      </xsl:when>
      <xsl:when test="$pica0500_2='F'">
        <mods:issuance>monographic</mods:issuance>
      </xsl:when>
      <xsl:when test="$pica0500_2='j'">
        <mods:issuance>single unit</mods:issuance>
      </xsl:when>
      <xsl:when test="$pica0500_2='s'">
        <mods:issuance>single unit</mods:issuance>
      </xsl:when>
      <xsl:when test="$pica0500_2='v'">
        <mods:issuance>serial</mods:issuance>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="common_edition">
    <xsl:param name="record" />
    <xsl:for-each select="$record/p:datafield[@tag='032@']"> <!-- 4020 Ausgabe -->
      <mods:edition>
        <xsl:choose>
          <xsl:when test="./p:subfield[@code='h']">
            <xsl:value-of select="./p:subfield[@code='a']" />
            /
            <xsl:value-of select="./p:subfield[@code='h']" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="./p:subfield[@code='a']" />
          </xsl:otherwise>
        </xsl:choose>
      </mods:edition>
    </xsl:for-each>
  </xsl:template>


  <xsl:template name="common_date_issued">
    <xsl:param name="datafield" />
    <xsl:choose>
      <xsl:when test="$datafield/p:subfield[@code='b']">
        <mods:dateIssued keyDate="yes" encoding="w3cdtf" point="start">
          <xsl:value-of select="translate($datafield/p:subfield[@code='a'], 'X','0')" />
        </mods:dateIssued>
        <mods:dateIssued encoding="w3cdtf" point="end">
          <xsl:value-of select="translate($datafield/p:subfield[@code='b'], 'X', '9')" />
        </mods:dateIssued>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="contains($datafield/p:subfield[@code='a'], 'X')">
            <mods:dateIssued keyDate="yes" encoding="w3cdtf" point="start">
              <xsl:value-of select="translate($datafield/p:subfield[@code='a'], 'X','0')" />
            </mods:dateIssued>
            <mods:dateIssued encoding="w3cdtf" point="end">
              <xsl:value-of select="translate($datafield/p:subfield[@code='a'], 'X', '9')" />
            </mods:dateIssued>
          </xsl:when>
          <xsl:otherwise>
            <mods:dateIssued keyDate="yes" encoding="w3cdtf">
              <xsl:value-of select="$datafield/p:subfield[@code='a']" />
            </mods:dateIssued>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$datafield/p:subfield[@code='n']">
      <mods:dateIssued>
        <xsl:value-of select="$datafield/p:subfield[@code='n']" />
      </mods:dateIssued>
    </xsl:if>
  </xsl:template>
  
  <!-- identisch mit common_date_issued, bis auf Elementnamen -->
  <xsl:template name="common_date_created">
    <xsl:param name="datafield" />
    <xsl:choose>
      <xsl:when test="$datafield/p:subfield[@code='b']">
        <mods:dateCreated keyDate="yes" encoding="w3cdtf" point="start">
          <xsl:value-of select="translate($datafield/p:subfield[@code='a'], 'X','0')" />
        </mods:dateCreated>
        <mods:dateCreated encoding="w3cdtf" point="end">
          <xsl:value-of select="translate($datafield/p:subfield[@code='b'], 'X', '9')" />
        </mods:dateCreated>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="contains($datafield/p:subfield[@code='a'], 'X')">
            <mods:dateCreated keyDate="yes" encoding="w3cdtf" point="start">
              <xsl:value-of select="translate($datafield/p:subfield[@code='a'], 'X','0')" />
            </mods:dateCreated>
            <mods:dateCreated encoding="w3cdtf" point="end">
              <xsl:value-of select="translate($datafield/p:subfield[@code='a'], 'X', '9')" />
            </mods:dateCreated>
          </xsl:when>
          <xsl:otherwise>
            <mods:dateCreated keyDate="yes" encoding="w3cdtf">
              <xsl:value-of select="$datafield/p:subfield[@code='a']" />
            </mods:dateCreated>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$datafield/p:subfield[@code='n']">
      <mods:dateCreated>
        <xsl:value-of select="$datafield/p:subfield[@code='n']" />
      </mods:dateCreated>
    </xsl:if>
  </xsl:template>


  <!-- ähnlich zu common_date_issued, ohne Behandlung der XX-Fälle -->
  <xsl:template name="common_date_captured">
    <xsl:param name="datafield" />
    <xsl:choose>
      <xsl:when test="$datafield/p:subfield[@code='b']">
        <mods:dateCaptured encoding="w3cdtf" keyDate="yes" point="start">
          <xsl:value-of select="$datafield/p:subfield[@code='a']" />
        </mods:dateCaptured>
        <mods:dateCaptured encoding="w3cdtf" point="end">
          <xsl:value-of select="$datafield/p:subfield[@code='b']" />
        </mods:dateCaptured>
      </xsl:when>
      <xsl:otherwise>
        <mods:dateCaptured encoding="w3cdtf" keyDate="yes">
          <xsl:value-of select="$datafield/p:subfield[@code='a']" />
        </mods:dateCaptured>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$datafield/p:subfield[@code='n']">
      <mods:dateCaptured>
        <xsl:value-of select="$datafield/p:subfield[@code='n']" />
      </mods:dateCaptured>
    </xsl:if>
  </xsl:template>

  <!-- normierte Orte 4040, außer Hochschulort $4=uvp -->
  <!-- PPN: 896299511 Petropoli -> Sankt Petersburg -->
  <xsl:template name="common_norm_place">
    <xsl:param name="record" />

    <xsl:for-each select="$record/p:datafield[@tag='033D' and not(./p:subfield[@code='4']='uvp')]">
      <mods:place supplied="yes">
        <mods:placeTerm lang="ger" type="text">
          <xsl:if test="./p:subfield[@code='9']">
            <xsl:variable name="pOrt"
              select="pica2mods:queryPicaFromUnAPIWithPPN($MCR.PICA2MODS.DATABASE, ./p:subfield[@code='9'])" />
            <xsl:attribute name="authorityURI">http://d-nb.info/gnd/</xsl:attribute>
            <xsl:attribute name="valueURI"><xsl:value-of
              select="$pOrt/p:datafield[@tag='003U']/p:subfield[@code='a']" /></xsl:attribute>
          </xsl:if>
          <xsl:value-of select="./p:subfield[@code='p']" />
        </mods:placeTerm>
      </mods:place>
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>
