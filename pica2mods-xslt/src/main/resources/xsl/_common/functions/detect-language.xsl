<?xml version="1.0"?>
<xsl:stylesheet version="3.0" xmlns:pica2mods="http://www.mycore.org/pica2mods/xsl/functions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:p="info:srw/schema/5/picaXML-v1.0" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" 
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:err="http://www.w3.org/2005/xqt-errors"
  exclude-result-prefixes="mods fn xs err map pica2mods p xlink array">


  <xsl:function name="pica2mods:detectLanguage" as="xs:string">
    <xsl:param name="text" as="xs:string" />
  
    <xsl:variable name="words" as="map(xs:string, array(xs:string))">
      <xsl:map>
        <xsl:map-entry key="'ger'"
          select="['als', 'am', 'auch', 'auf', 'aus', 'bei', 'bis', 'das', 'dem', 'den', 'der', 'deren', 'derer', 'des', 'dessen', 'die', 'dies', 'diese', 'dieser', 'dieses', 'ein', 'eine', 'einer', 'eines', 'einem', 'für', 'hat', 'im', 'ist', 'mit', 'sich', 'sie', 'über', 'und', 'vom', 'von', 'vor', 'wie', 'zu', 'zum', 'zur']" />
        <xsl:map-entry key="'eng'"
          select="['a', 'and', 'are', 'as', 'at', 'do', 'for', 'from', 'has', 'have', 'how', 'its', 'like', 'new', 'of', 'on', 'or', 'the', 'their', 'through', 'to', 'with', 'you', 'your']" />
        <xsl:map-entry key="'fre'"
          select="['la', 'le', 'les', 'un', 'une', 'des,', 'à', 'aux', 'de', 'pour', 'par', 'sur', 'comme', 'aussi', 'quel', 'quels', 'quelles', 'laquelle', 'lequel', 'lesquelles', 'lesquelles', 'auxquels', 'auxquelles', 'avec', 'sans', 'ont', 'sont', 'duquel', 'desquels', 'desquelles', 'quand']" />
      </xsl:map>
    </xsl:variable>
  
    <xsl:variable name="endings" as="map(xs:string, array(xs:string))">
      <xsl:map>
        <xsl:map-entry key="'ger'"
          select="['ag', 'chen', 'gen', 'ger', 'iche', 'icht', 'ig', 'ige', 'isch', 'ische', 'ischen', 'kar', 'ker', 'keit', 'ler', 'mus', 'nen', 'ner', 'rie', 'rer', 'ter', 'ten', 'trie', 'tz', 'ung', 'yse']" />
        <xsl:map-entry key="'eng'"
          select="['ar', 'ble', 'cal', 'ce', 'ced', 'ed', 'ent', 'ic', 'ies', 'ing', 'ive', 'ness', 'our', 'ous', 'ons', 'ral', 'th', 'ure', 'y']" />
        <xsl:map-entry key="'fre'"
          select="['é', 'és', 'ée', 'ées', 'euse', 'euses', 'ème', 'euil', 'asme', 'isme', 'aux']" />
      </xsl:map>
    </xsl:variable>
    <xsl:variable name="data" select="tokenize(lower-case($text))"></xsl:variable>
  
    <xsl:variable name="wordCounts" as="item()*">
      <counts>
        <xsl:for-each select="map:for-each($words, function($k, $v){$k})">
          <count lang="{.}">
            <xsl:value-of
              select="
            sum(
              array:for-each(map:get($words, .), 
                function($a){
                  fn:for-each($data, function($b){if($a = $b) then 2 else 0})
                }
              )
            ) 
           + sum(
            array:for-each(map:get($endings, .), 
                function($a){
                  fn:for-each($data, function($b){if(ends-with($b,$a)) then 1 else 0})
                }
              )
           )" />
          </count>
        </xsl:for-each>
        <!-- default -->
        <count lang="mis">1</count>
      </counts>
    </xsl:variable>
    <xsl:message select="$wordCounts" />
    <xsl:value-of select="$wordCounts/count[.= max(../count)]/@lang" />
  </xsl:function>
</xsl:stylesheet>

