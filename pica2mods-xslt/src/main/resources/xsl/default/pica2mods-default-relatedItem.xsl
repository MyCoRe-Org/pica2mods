<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
                xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="mods pica2mods">

  <xsl:import use-when="system-property('XSL_TESTING')='true'" href="_common/pica2mods-functions.xsl" />

  <xsl:template name="modsRelatedItem">
    <xsl:for-each select="./p:datafield[@tag='039B']"> <!-- 4241 Beziehungen zur größeren Einheit -->
      <xsl:call-template name="COMMON_AppearsIn" />
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='036D']"> <!-- 4160 übergeordnetes Werk -->
      <xsl:call-template name="COMMON_HostOrSeries" />
    </xsl:for-each>

    <!--TODO: Unterscheidung nach 0500 2. Pos: wenn 'v' dann type->host, sonst type->series -->
    <xsl:for-each select="./p:datafield[@tag='036F']"> <!-- 4180 Schriftenreihe, Zeitschrift -->
      <xsl:call-template name="COMMON_HostOrSeries" />
    </xsl:for-each>

    <xsl:for-each select="./p:datafield[@tag='039P']"> <!-- 4261 RezensiertesWerk -->
      <xsl:call-template name="COMMON_Review" />
    </xsl:for-each>
    
    <xsl:for-each select="./p:datafield[@tag='039D']"> <!-- 4243 Beziehungen auf Manifestationsebene -->
      <xsl:call-template name="COMMON_Manifestation" />
    </xsl:for-each>

    <xsl:call-template name="common_relatedItemPreceding" />
  </xsl:template>

  <xsl:template name="COMMON_HostOrSeries">
    <mods:relatedItem>
      <xsl:if test="./p:subfield[@code='9']">
        <xsl:variable name="od"
          select="pica2mods:queryPicaFromUnAPIWithPPN('k10plus', ./p:subfield[@code='9'])" />
        <xsl:choose>
          <xsl:when
            test="$od/p:datafield[@tag='017C']/p:subfield[@code='u'][starts-with(.,'http://purl.uni-rostock.de/')][1]">
            <xsl:for-each
              select="$od/p:datafield[@tag='017C']/p:subfield[@code='u'][starts-with(.,'http://purl.uni-rostock.de/')][1]">
              <xsl:attribute name="type">host</xsl:attribute>

              <mods:recordInfo>
                <mods:recordIdentifier source="DE-28">
                  <xsl:value-of select="substring(.,28,100) " />
                </mods:recordIdentifier>
              </mods:recordInfo>
              <mods:identifier type="purl">
                <xsl:value-of select="." />
              </mods:identifier>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="type">series</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        <mods:identifier type="PPN">
          <xsl:value-of select="$od/p:datafield[@tag='003@']/p:subfield[@code='0']" />
        </mods:identifier>
        <xsl:if test="$od/p:datafield[@tag='006Z']/p:subfield[@code='0']">
          <mods:identifier type="zdb">
            <xsl:value-of select="$od/p:datafield[@tag='006Z']/p:subfield[@code='0']" />
          </mods:identifier>
        </xsl:if>
      </xsl:if>
      <xsl:if test="not(./p:subfield[@code='9'])">
        <xsl:attribute name="type">series</xsl:attribute>
      </xsl:if>

      <!-- ToDo teilweise redundant mit title template -->
      <mods:titleInfo>
        <xsl:if test="./p:subfield[@code='a']">
          <xsl:variable name="mainTitle" select="./p:subfield[@code='a'][1]" />
          <xsl:choose>
            <xsl:when test="contains($mainTitle, '@')">
              <xsl:variable name="nonSort" select="normalize-space(substring-before($mainTitle, '@'))" />
              <xsl:choose>
                <xsl:when test="string-length(nonSort) &lt; 9">
                  <mods:nonSort>
                    <xsl:value-of select="$nonSort" />
                  </mods:nonSort>
                  <mods:title>
                    <xsl:value-of select="substring-after($mainTitle, '@')" />
                  </mods:title>
                </xsl:when>
                <xsl:otherwise>
                  <mods:title>
                    <xsl:value-of select="$mainTitle" />
                  </mods:title>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <mods:title>
                <xsl:value-of select="$mainTitle" />
              </mods:title>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </mods:titleInfo>

      <mods:part>
        <!-- set order attribute only if value of subfield $X is a number -->
        <xsl:if test="./p:subfield[@code='X']">
          <xsl:choose>
            <!-- sort string contains 2 commas -->
            <xsl:when
              test="string-length(./p:subfield[@code='X']) = string-length(translate(./p:subfield[@code='X'], ',','')) + 2">
              <xsl:if test="number(translate(./p:subfield[@code='X'], ',',''))">
                <xsl:attribute name="order">
                                    <xsl:value-of select="translate(./p:subfield[@code='X'], ',','')" />
                                </xsl:attribute>
              </xsl:if>
            </xsl:when>
            <xsl:when test="contains(./p:subfield[@code='X'], ',')">
              <xsl:if test="number(substring-before(substring-before(./p:subfield[@code='X'], '.'), ','))">
                <xsl:attribute name="order">
                                    <xsl:value-of
                  select="substring-before(substring-before(./p:subfield[@code='X'], '.'), ',')" />
                                </xsl:attribute>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="number(substring-before(./p:subfield[@code='X'], '.'))">
                <xsl:attribute name="order">
                                    <xsl:value-of select="substring-before(./p:subfield[@code='X'], '.')" />
                                </xsl:attribute>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>

        <!-- ToDo: type attribute: issue, volume, chapter, .... -->
        <xsl:if test="./p:subfield[@code='l']">
          <mods:detail type="volume">
            <mods:number>
              <xsl:value-of select="./p:subfield[@code='l']" />
            </mods:number>
          </mods:detail>
        </xsl:if>
        <xsl:if test="(@tag='036D' or @tag='036F') and ./p:subfield[@code='X']"> <!-- 4160, 4180 -->
          <mods:text type="sortstring">
            <xsl:value-of select="pica2mods:sortableSortstring(./p:subfield[@code='X'])" />
          </mods:text>
        </xsl:if>
      </mods:part>
    </mods:relatedItem>
  </xsl:template>

  <xsl:template name="COMMON_AppearsIn">
    <mods:relatedItem>
      <xsl:attribute name="otherType">appears_in</xsl:attribute>

      <xsl:variable name="pica0500_2" select="substring(./../p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
      <xsl:variable name="parent">
        <xsl:if test="./p:subfield[@code='9']">
          <xsl:copy-of select="pica2mods:queryPicaFromUnAPIWithPPN('k10plus', ./p:subfield[@code='9'])" />
        </xsl:if>
      </xsl:variable>
            
      <xsl:choose>
        <xsl:when test="$pica0500_2='s'">
          <xsl:attribute name="type">host</xsl:attribute>
          <mods:part>
            <xsl:for-each select="./../p:datafield[@tag='031A']"> <!-- 4070 Differenzierende Angaben zur Quelle -->
              <xsl:if test="./p:subfield[@code='h']">
                <mods:extent unit="pages">
                  <mods:list>
                    <xsl:value-of select="concat('Seiten ',./p:subfield[@code='h'])" />
                  </mods:list>
                </mods:extent>
              </xsl:if>

            </xsl:for-each>  
            <xsl:if test="./p:subfield[@code='x']">
              <mods:text type="sortstring">
               <xsl:value-of select="pica2mods:sortableSortstring(./p:subfield[@code='x'])" />
              </mods:text>
            </xsl:if>
          </mods:part>
          <xsl:choose>
            <!-- NICHT A ODER B = keine Rostock-PURL am Aufsatz ODER Rostock-PURL am Host -->
            <xsl:when test="not(../p:datafield[@tag='017C']/p:subfield[@code='u'][starts-with(.,'http://purl.uni-rostock.de/')]) or $parent/p:record/p:datafield[@tag='017C']/p:subfield[@code='u'][starts-with(.,'http://purl.uni-rostock.de/')]">
              <xsl:variable name="parentMODS">
                <xsl:apply-templates select="$parent" />
              </xsl:variable>
              <xsl:copy-of select="$parentMODS/mods:mods/*" />
            </xsl:when>
            <xsl:otherwise>
              <!-- Haben wir Os-Sätze ohne zugehörige Zeitschriftenaufsätze, die nicht auf RosDok sind? -->
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$pica0500_2='a'">
          <xsl:choose>
            <xsl:when test="$parent//p:datafield">
              <xsl:variable name="parentMODS">
                <xsl:apply-templates select="$parent" />
              </xsl:variable>
              <xsl:copy-of select="$parentMODS/mods:mods/*" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="./p:subfield[@code='t']">
                <mods:titleInfo>
                  <mods:title>
                    <xsl:value-of select="./p:subfield[@code='t']" />
                  </mods:title>
                </mods:titleInfo>
              </xsl:if>
              <xsl:if test="./p:subfield[@code='f' or @code='d' or @code='e']">
                <mods:originInfo eventType="publication">
                  <xsl:if test="./p:subfield[@code='f']">
                    <mods:dateIssued keyDate="yes" encoding="w3cdtf">
                      <xsl:value-of select="./p:subfield[@code='f']" />
                    </mods:dateIssued>
                  </xsl:if>
                  <xsl:if test="./p:subfield[@code='e']">
                    <mods:publisher><xsl:value-of select="./p:subfield[@code='e']" /></mods:publisher>
                  </xsl:if>
                  <xsl:if test="./p:subfield[@code='d']">
                    <mods:place>
                      <mods:placeTerm type="text"><xsl:value-of select="./p:subfield[@code='d']" /></mods:placeTerm>
                    </mods:place>
                  </xsl:if>
                </mods:originInfo>
              </xsl:if>
              <xsl:if test="./p:subfield[@code='p']">
                <mods:part>
                  <mods:text>
                    <xsl:value-of select="./p:subfield[@code='p']" />
                 </mods:text>
               </mods:part>
              </xsl:if>
              <xsl:if test="./p:subfield[@code='l']">
                <mods:name>
                  <mods:displayForm>
                    <xsl:value-of select="./p:subfield[@code='l']" />
                  </mods:displayForm>
                </mods:name>
              </xsl:if>
              <xsl:if test="./p:subfield[@code='C' and text()='DOI']">
                <mods:identifier type="doi">
                  <xsl:value-of select="./p:subfield[@code='C' and text()='DOI']/following-sibling::p:subfield[@code='6'][1]" />
                </mods:identifier>
              </xsl:if>
              <xsl:if test="./p:subfield[@code='C' and text()='ISBN']">
                <mods:identifier type="isbn">
                  <xsl:value-of select="./p:subfield[@code='C' and text()='ISBN']/following-sibling::p:subfield[@code='6'][1]" />
                </mods:identifier>
              </xsl:if>
              <xsl:if test="./p:subfield[@code='C' and text()='ISSN']">
                <mods:identifier type="issn">
                  <xsl:value-of select="./p:subfield[@code='C' and text()='ISSN']/following-sibling::p:subfield[@code='6'][1]" />
                </mods:identifier>
              </xsl:if>
              <xsl:if test="./p:subfield[@code='C' and text()='ZDB']">
                <mods:identifier type="zdb">
                  <xsl:value-of select="./p:subfield[@code='C' and text()='ZDB']/following-sibling::p:subfield[@code='6'][1]" />
                </mods:identifier>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>
    </mods:relatedItem>
  </xsl:template>

  <xsl:template name="COMMON_Review">
    <mods:relatedItem type="reviewOf">
      <mods:titleInfo>
        <xsl:if test="./p:subfield[@code='a']">
          <xsl:variable name="mainTitle" select="./p:subfield[@code='a']" />
          <xsl:choose>
            <xsl:when test="contains($mainTitle, '@')">
              <xsl:variable name="nonSort" select="normalize-space(substring-before($mainTitle, '@'))" />
              <xsl:choose>
                <xsl:when test="string-length(nonSort) &lt; 9">
                  <mods:nonSort>
                    <xsl:value-of select="$nonSort" />
                  </mods:nonSort>
                  <mods:title>
                    <xsl:value-of select="substring-after($mainTitle, '@')" />
                  </mods:title>
                </xsl:when>
                <xsl:otherwise>
                  <mods:title>
                    <xsl:value-of select="$mainTitle" />
                  </mods:title>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <mods:title>
                <xsl:value-of select="$mainTitle" />
              </mods:title>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </mods:titleInfo>
      <mods:identifier type="PPN">
        <xsl:value-of select="./p:subfield[@code='9']" />
      </mods:identifier>
    </mods:relatedItem>
  </xsl:template>

  <!-- Vorgänger, Nachfolger Verknüpfung ZDB -->
  <xsl:template name="common_relatedItemPreceding">
    <xsl:variable name="pica0500_2"
      select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
    <xsl:if test="$pica0500_2='b'">
      <xsl:for-each
        select="./p:datafield[@tag='039E' and (./p:subfield[@code='b' and text()='f'] or ./p:subfield[@code='b'and text()='s'])]"><!-- 4244 -->
        <mods:relatedItem>
          <xsl:if test="./p:subfield[@code='b' and text()='f']">
            <xsl:attribute name="type">preceding</xsl:attribute>
          </xsl:if>
          <xsl:if test="./p:subfield[@code='b' and text()='s']">
            <xsl:attribute name="type">succeeding</xsl:attribute>
          </xsl:if>
          <xsl:if test="./p:subfield[@code='t']">
            <mods:titleInfo>
              <mods:title>
                <xsl:value-of select="./p:subfield[@code='t']" />
              </mods:title>
            </mods:titleInfo>
          </xsl:if>
          <xsl:if test="./p:subfield[@code='C' and text()='ZDB']">
            <mods:identifier type="zdb">
              <xsl:value-of
                select="./p:subfield[@code='C' and text()='ZDB']/following-sibling::p:subfield[@code='6'][1]" />
            </mods:identifier>
          </xsl:if>
        </mods:relatedItem>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
  
   <xsl:template name="COMMON_Manifestation">
     <xsl:choose>
      <xsl:when test="./p:subfield[@code='C' and text()='DOI']">
        <mods:relatedItem type="otherFormat">
          <mods:identifier type="doi">
          <xsl:value-of select="./p:subfield[@code='C' and text()='DOI']/following-sibling::p:subfield[@code='6'][1]" />
          </mods:identifier>
          <xsl:if test="./p:subfield[@code='n']">
            <mods:note type="format_type"><xsl:value-of select="./p:subfield[@code='n']" /></mods:note>
          </xsl:if>
        </mods:relatedItem>
      </xsl:when>
      <xsl:when test="./p:subfield[@code='9']">
        <xsl:variable name="parent" select="pica2mods:queryPicaFromUnAPIWithPPN('k10plus', ./p:subfield[@code='9'])" />
        <xsl:if test="starts-with($parent/p:datafield[@tag='002@']/p:subfield[@code='0'], 'O') and $parent/p:datafield[@tag='004V']">
          <mods:relatedItem type="otherFormat">
            <mods:identifier type="doi">
              <xsl:value-of select="$parent/p:datafield[@tag='004V']/p:subfield[@code='0']" />
            </mods:identifier>
            <xsl:if test="./p:subfield[@code='n']">
              <mods:note type="format_type"><xsl:value-of select="./p:subfield[@code='n']" /></mods:note>
           </xsl:if>
        </mods:relatedItem>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
