package org.mycore.pica2mods.controller;

import java.io.StringReader;
import java.io.StringWriter;
import java.util.Iterator;

import javax.xml.XMLConstants;
import javax.xml.namespace.NamespaceContext;
import javax.xml.transform.Result;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.mycore.pica2mods.Pica2ModsGenerator;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.xml.sax.InputSource;

@Service
public class Pica2ModsXSLTransformerService {
    /*
     * Attention leading slash: ClassLoader.getResourceAsStream
     * ("some/pkg/resource.properties"); Class.getResourceAsStream
     * ("/some/pkg/resource.properties");
     */
    public static String CLASSPATH_PREFIX = "META-INF/resources/xsl/pica2mods/";
    // public static String XPATH_APPN =
    // "/p:record/p:datafield[@tag='039I'][./p:subfield[@code='C']='GBV']/p:subfield[@code='6']/text()";
    // public static String XPATH_HOST_PPN = "/p:record/p:datafield[@tag='036D' or
    // @tag='036F']/p:subfield[@code='9']/text()";
    public static String XPATH_APPN = "/mods:mods/mods:note[@type='PPN-A']/text()";
    public static String XPATH_HOST_PPN = "/mods:mods/mods:relatedItem/mods:recordInfo/mods:recordIdentifier[@source='DE-28']/text()";

    @Value("${pica2mods.sru.url}")
    private String sruURL;

    @Value("${pica2mods.unapi.url}")
    private String unapiURL;

    @Value("${pica2mods.mycore.base.url}")
    private String mycoreBaseURL;

    public String transform(String ppn) {
        StringWriter sw = new StringWriter();
        Result result = new StreamResult(sw);

        Pica2ModsGenerator pica2modsGenerator = new Pica2ModsGenerator(sruURL, unapiURL, mycoreBaseURL);
        ;
        pica2modsGenerator.createMODSDocumentFromSRU("pica.ppn=" + ppn, result);
        return sw.toString();
    }

    public String retrieveAPPN(String modsXml) {

        try {

            XPathFactory factory = XPathFactory.newInstance();

            XPath xpath = factory.newXPath();
            xpath.setNamespaceContext(new MyNamespaceContext());

            XPathExpression expression = xpath.compile(XPATH_APPN);
            return expression.evaluate(new InputSource(new StringReader(modsXml)));

        } catch (XPathExpressionException e) {

            e.printStackTrace();
        }

        return null;
    }

    public String retrieveHostPPN(String modsXml) {

        try {
            XPathFactory factory = XPathFactory.newInstance();

            XPath xpath = factory.newXPath();
            xpath.setNamespaceContext(new MyNamespaceContext());

            XPathExpression expression = xpath.compile(XPATH_HOST_PPN);
            String hostRecordIdentifier = expression.evaluate(new InputSource(new StringReader(modsXml)));
            if (hostRecordIdentifier != null && hostRecordIdentifier.contains("/ppn")) {
                return hostRecordIdentifier.substring(hostRecordIdentifier.lastIndexOf("/ppn") + 4);
            }
        } catch (XPathExpressionException e) {

            e.printStackTrace();
        }

        return null;
    }

    class MyNamespaceContext implements NamespaceContext {
        public String getNamespaceURI(String prefix) {
            if (prefix.equals("p")) {
                return "info:srw/schema/5/picaXML-v1.0";
            } else if (prefix.equals("mods")) {
                return "http://www.loc.gov/mods/v3";
            } else {
                return XMLConstants.NULL_NS_URI;
            }
        }

        public String getPrefix(String namespace) {
            if (namespace.equals("info:srw/schema/5/picaXML-v1.0")) {
                return "p";
            } else if (namespace.equals("http://www.loc.gov/mods/v3")) {
                return "mods";
            }

            else {
                return null;
            }
        }

        @SuppressWarnings({ "rawtypes", "unchecked" })
        public Iterator getPrefixes(String namespace) {
            return null;
        }
    }
}
