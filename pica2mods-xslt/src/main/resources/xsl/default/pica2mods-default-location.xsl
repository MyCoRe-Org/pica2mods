<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsL="http://www.w3.org/1999/XSL/Transform" version="3.0"
                exclude-result-prefixes="mods">

    <xsl:import use-when="system-property('XSL_TESTING')='true'" href="picaMode.xsl" />
    <xsl:import use-when="system-property('XSL_TESTING')='true'" href="picaURLResolver.xsl"/>
    <xsl:import use-when="system-property('XSL_TESTING')='true'" href="picaDate.xsl"/>

    <!-- This template is for testing purposes-->
    <xsl:template match="p:record">
        <mods:mods>
            <xsl:call-template name="modsLocation" />
        </mods:mods>
    </xsl:template>

    <xsl:template name="modsLocation">
        <xsl:variable name="picaMode">
            <xsl:call-template name="detectPicaMode"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$picaMode = $pica_RDA">
                <xsl:for-each select="./p:datafield[@tag='009A']"> <!-- 4065 Besitznachweis der Vorlage, RDA ok -->
                    <mods:location>
                        <xsl:if test="./p:subfield[@code='c']">
                            <xsl:choose>
                                <xsl:when test="./p:subfield[@code='c']='UB Rostock'">
                                    <mods:physicalLocation type="current" authorityURI="http://d-nb.info/gnd/" valueURI="http://d-nb.info/gnd/25968-8">Universitätsbibliothek Rostock</mods:physicalLocation>
                                </xsl:when>
                                <xsl:otherwise>
                                    <mods:physicalLocation type="current">
                                        <xsl:value-of select="./p:subfield[@code='c']" />
                                    </mods:physicalLocation>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                        <xsl:if test="./p:subfield[@code='a']">
                            <mods:shelfLocator>
                                <xsl:value-of select="./p:subfield[@code='a']" />
                            </mods:shelfLocator>
                        </xsl:if>
                    </mods:location>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$picaMode = $pica_KXP">
                <xsl:for-each select="./p:datafield[@tag='017C' and contains(./p:subfield[@code='u'], '//purl.uni-rostock.de')][1]">
                    <mods:location>
                        <!-- TODO: delete/generalize rostok specific code -->
                        <mods:physicalLocation type="online" authorityURI="http://d-nb.info/gnd/" valueURI="http://d-nb.info/gnd/25968-8">Universitätsbibliothek Rostock</mods:physicalLocation>
                        <mods:url usage="primary" access="object in context"><xsl:value-of select="./p:subfield[@code='u']" /></mods:url>
                    </mods:location>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$picaMode = $pica_EPUB">
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
            </xsl:when>
        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>
