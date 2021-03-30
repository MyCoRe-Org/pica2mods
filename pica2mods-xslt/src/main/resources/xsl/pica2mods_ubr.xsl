<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:p="info:srw/schema/5/picaXML-v1.0"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink">
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:import href="ubr/pica2mods-ubr-recordInfo.xsl" />
  <xsl:import href="ubr/pica2mods-ubr-genre.xsl" />
  <xsl:import href="default/pica2mods-default-genre.xsl" />
  <xsl:import href="default/pica2mods-default-titleInfo.xsl" />
  <xsl:import href="default/pica2mods-default-name.xsl" />
  <xsl:import href="ubr/pica2mods-ubr-identifier.xsl" />
  <xsl:import href="default/pica2mods-default-identifier.xsl" />
  <xsl:import href="ubr/pica2mods-ubr-classification.xsl" />
  <xsl:import href="default/pica2mods-default-language.xsl" />
  <xsl:import href="default/pica2mods-default-location.xsl" />
  <xsl:import href="default/pica2mods-default-physicalDescription.xsl" />
  <xsl:import href="default/pica2mods-default-originInfo.xsl" />
  <xsl:import href="default/pica2mods-default-note.xsl" />
  <xsl:import href="default/pica2mods-default-abstract.xsl" />
  <xsl:import href="default/pica2mods-default-subject.xsl" />
  <xsl:import href="default/pica2mods-default-relatedItem.xsl" />

  <xsl:import href="ubr/pica2mods-ubr-POSTPROCESSING.xsl" />

  <xsl:import href="_common/pica2mods-functions.xsl" />
  <xsl:param name="MCR.PICA2MODS.CONVERTER_VERSION" select="'Pica2Mods 2.0'" />
  <!-- TO: MyCoRe-AnwendungsURL -->
  <xsl:param name="WebApplicationBaseURL" select="'http://rosdok.uni-rostock.de/'" />


  <xsl:template match="p:record">
    <xsl:variable name="mods_orig">
      <mods:mods>
        <xsl:call-template name="modsRecordInfo" />
        <xsl:call-template name="UBR_modsGenre_Doctype" />
        <xsl:call-template name="modsGenre" />
        <xsl:call-template name="modsTitleInfo" />
        <xsl:call-template name="modsAbstract" />
        <xsl:call-template name="modsName" />
        <xsl:call-template name="UBR_modsIdentifier" />
        <xsl:call-template name="modsIdentifier" />
        <xsl:call-template name="modsClassification" />
        <xsl:call-template name="modsLanguage" />
        <xsl:call-template name="modsPhysicalDescription" />
        <xsl:call-template name="modsOriginInfo" />
        <xsl:call-template name="modsLocation" />
        <xsl:call-template name="modsNote" />
        <xsl:call-template name="modsRelatedItem" />
        <xsl:call-template name="modsSubject" />
      </mods:mods>
    </xsl:variable>
    <xsl:apply-templates select="$mods_orig" mode="ubrPostProcessing" />

  </xsl:template>

</xsl:stylesheet>
