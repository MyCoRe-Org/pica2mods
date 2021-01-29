<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="3.0"
                exclude-result-prefixes="mods">

    <xsl:import href="pica2mods-default-modsTitleInfo.xsl"/>
    <xsl:import href="pica2mods-default-modsName.xsl"/>
    <xsl:import href="pica2mods-default-modsIdentifier.xsl"/>
    <xsl:import href="pica2mods-default-modsLanguage.xsl"/>

    <xsl:import href="picaMode.xsl"/>
    <xsl:import href="picaURLResolver.xsl"/>

    <xsl:template match="p:record">
        <mods:mods>
           <xsl:call-template name="modsTitleInfo" />
           <xsl:call-template name="modsName" />
           <xsl:call-template name="modsIdentifier" />
           <xsl:call-template name="modsLanguage" />
        </mods:mods>
    </xsl:template>

</xsl:stylesheet>
