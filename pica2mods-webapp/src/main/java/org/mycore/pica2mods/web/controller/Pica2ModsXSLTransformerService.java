package org.mycore.pica2mods.web.controller;

import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.transform.Result;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.mycore.pica2mods.web.Pica2ModsNamespaceContext;
import org.mycore.pica2mods.web.Pica2ModsWebapp;
import org.mycore.pica2mods.web.model.PPNLink;
import org.mycore.pica2mods.xsl.Pica2ModsGenerator;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.thymeleaf.util.StringUtils;
import org.xml.sax.InputSource;

@Service
public class Pica2ModsXSLTransformerService {
    /*
     * Attention leading slash: ClassLoader.getResourceAsStream
     * ("some/pkg/resource.properties"); Class.getResourceAsStream
     * ("/some/pkg/resource.properties");
     */
    public static String CLASSPATH_PREFIX = "xsl/";

    public static String XPATH_PARALLEL = "concat(//p:datafield[@tag='039D']/p:subfield[@code='n'], //p:datafield[@tag='039D']/p:subfield[@code='i' and not(./../p:subfield[@code='n'])], '|',//p:datafield[@tag='039D']/p:subfield[@code='C' and text()='KXP']/following-sibling::p:subfield[@code='6'][1])";

    public static String XPATH_PPN_MBW = "//p:datafield[@tag='036D']/p:subfield[@code='9']";

    public static String XPATH_PPN_SERIES = "//p:datafield[@tag='036F']/p:subfield[@code='9']";

    @Value("${pica2mods.sru.url}")
    private String sruURL;

    @Value("${pica2mods.unapi.url}")
    private String unapiURL;

    @Value("${pica2mods.mycore.base.url}")
    private String mycoreBaseURL;

    @Value("#{${pica2mods.catalogs.unapikeys}}")
    private Map<String, String> catalogUnapiKeys;
    
    @Value("#{${pica2mods.catalogs.srudbs}}")
    private Map<String, String> catalogSRUDBs;

    @Value("#{${pica2mods.catalogs.xsls}}")
    private Map<String, String> catalogXSLs;

    private XPathFactory factory = XPathFactory.newInstance();

    public String transform(String catalog, String ppn) {
        StringWriter sw = new StringWriter();
        Result result = new StreamResult(sw);

        Pica2ModsGenerator pica2modsGenerator = new Pica2ModsGenerator(sruURL, unapiURL, mycoreBaseURL);
        Map<String, String> xslParams = new HashMap<>();
        xslParams.put("MCR.PICA2MODS.CONVERTER_VERSION", Pica2ModsWebapp.PICA2MODS_VERSION);
        xslParams.put("MCR.PICA2MODS.DATABASE", catalogUnapiKeys.get(catalog));
        
        pica2modsGenerator.createMODSDocumentFromSRU(catalogSRUDBs.get(catalog), "pica.ppn=" + ppn,
            catalogXSLs.get(catalog), result, xslParams);

        return sw.toString();
    }

    public List<PPNLink> resolveOtherIssues(String catalog, String ppn) {
        List<PPNLink> result = new ArrayList<>();
        String url = unapiURL + "?format=picaxml&id=" + catalogUnapiKeys.get(catalog) + ":ppn:" + ppn;
        XPath xpath = factory.newXPath();
        xpath.setNamespaceContext(new Pica2ModsNamespaceContext());

        try (InputStream input = new URL(url).openStream()) {
            XPathExpression expression = xpath.compile(XPATH_PARALLEL);
            String s = expression.evaluate(new InputSource(input));
            if (s.length() > 1) {
                PPNLink p = new PPNLink(s.substring(0, s.indexOf("|")), s.substring(s.indexOf("|") + 1));
                result.add(p);
            }

        } catch (IOException | XPathExpressionException e) {
            //e.printStackTrace();
        }

        //MBW
        try (InputStream input = new URL(url).openStream()) {
            XPathExpression expression = xpath.compile(XPATH_PPN_MBW);
            String s = expression.evaluate(new InputSource(input));
            if (!StringUtils.isEmpty(s)) {
                result.add(new PPNLink("MBW", s));
            }

        } catch (IOException | XPathExpressionException e) {
            //e.printStackTrace();
        }

        //Schriftenreihe
        try (InputStream input = new URL(url).openStream()) {
            XPathExpression expression = xpath.compile(XPATH_PPN_SERIES);
            String s = expression.evaluate(new InputSource(input));
            if (!StringUtils.isEmpty(s)) {
                result.add(new PPNLink("Schriftenreihe", s));
            }

        } catch (IOException | XPathExpressionException e) {
            //e.printStackTrace();
        }

        return result;
    }

}
