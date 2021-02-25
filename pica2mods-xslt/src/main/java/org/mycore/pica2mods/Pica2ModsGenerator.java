package org.mycore.pica2mods;

import java.io.InputStream;
import java.io.StringReader;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.concurrent.TimeUnit;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class Pica2ModsGenerator {
    private final Logger LOGGER = LoggerFactory.getLogger(Pica2ModsGenerator.class);

    public static final String PICA2MODS_XSLT_PATH = "xsl/";

    private static final String NS_PICA = "info:srw/schema/5/picaXML-v1.0";

    private static DocumentBuilderFactory DBF;

    static {
        DBF = DocumentBuilderFactory.newInstance();
        DBF.setNamespaceAware(true);
    }

    public static Pica2ModsGenerator instanceForRosDok() {
        return new Pica2ModsGenerator("http://sru.k10plus.de", "http://unapi.k10plus.de",
            "http://rosdok.uni-rostock.de/");
    }

    private String sruURL;

    private String unapiURL;

    /**
     * baseURL for the corresponding MyCoRe Application ends with slash;
     */
    private String mycoreBaseURL;

    public String getMycoreBaseURL() {
        return mycoreBaseURL;
    }

    public Pica2ModsGenerator(String sruURL, String unapiURL, String mycoreBaseURL) {
        super();

        this.sruURL = sruURL;
        this.unapiURL = unapiURL;

        if (!mycoreBaseURL.endsWith("/")) {
            this.mycoreBaseURL = mycoreBaseURL + "/";
        } else {
            this.mycoreBaseURL = mycoreBaseURL;
        }
    }

    // http://sru.gbv.de/opac-de-28?operation=searchRetrieve&maximumRecords=1&recordSchema=picaxml&query=pica.ppn%3D1023803275
    public Element retrievePicaXMLViaSRU(String database, String sruQuery) throws Exception {
        URL url = new URL(
            sruURL + "/" + database + "?operation=searchRetrieve&maximumRecords=1&recordSchema=picaxml&query="
                + URLEncoder.encode(sruQuery, "UTF-8"));
        int loop = 0;
        Document document = null;
        do {
            loop++;
            LOGGER.debug("Getting catalogue data from: " + url.toString());
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            try (InputStream xmlStream = conn.getInputStream()) {
                DocumentBuilder dBuilder = DBF.newDocumentBuilder();
                document = dBuilder.parse(xmlStream);
            } catch (Exception e) {
                if (loop <= 2) {
                    LOGGER.error("An error occurred - waiting 5 min and try again", e);
                    TimeUnit.MINUTES.sleep(5);
                } else {
                    throw e;
                }
            }
        } while (document == null && loop <= 2);
        if (document == null) {
            String msg = "Could not retrieve Metadata from catalogue: " + url.toString();
            LOGGER.error(msg);
            throw new Pica2ModsException(msg);
        }

        NodeList nl = document.getElementsByTagNameNS(NS_PICA, "record");
        if (nl.getLength() > 0) {
            return (Element) nl.item(0);
        } else {
            String msg = "No Record found for: " + url.toString();
            LOGGER.error(msg);
            return document.createElement("nil");
        }
    }

    //http://unapi.k10plus.de/?&format=picaxml&id=opac-de-28:ppn:1662436106
    public Element retrievePicaXMLViaUnAPI(String catalogKey, String ppn) throws Exception {
        return retrievePicaXMLViaUnAPI(catalogKey + ":ppn:" + ppn);
    }

    public Element retrievePicaXMLViaUnAPI(String unapiID) throws Exception {
        URL url = new URL(unapiURL + "?format=picaxml&id=" + unapiID);
        int loop = 0;
        Document document = null;
        do {
            loop++;
            LOGGER.debug("Getting catalogue data from: " + url.toString());
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            try (InputStream xmlStream = conn.getInputStream()) {
                DocumentBuilder dBuilder = DBF.newDocumentBuilder();
                document = dBuilder.parse(xmlStream);
            } catch (Exception e) {
                if (loop <= 2) {
                    LOGGER.error("An error occurred - waiting 5 min and try again", e);
                    TimeUnit.MINUTES.sleep(5);
                } else {
                    throw e;
                }
            }
        } while (document == null && loop <= 2);
        if (document == null) {
            String msg = "Could not retrieve Metadata from catalogue: " + url.toString();
            LOGGER.error(msg);
            throw new Pica2ModsException(msg);
        }

        NodeList nl = document.getElementsByTagNameNS(NS_PICA, "record");
        if (nl.getLength() > 0) {
            return (Element) nl.item(0);
        } else {
            String msg = "No Record found for: " + url.toString();
            LOGGER.error(msg);
            return document.createElement("nil");
        }
    }

    public void createMODSDocumentFromSRU(String catalogKey, String sruQuery, String xslFile, Result result) {
        //uses the configured Transformer-Factory (e.g. XALAN, if installed)
        //TransformerFactory TRANS_FACTORY = TransformerFactory.newInstance();
        //Java 9 provides a method newDefaultInstance() to retrieve the built-in system default implementation

        //for Java 8 we set the class name explicitely
        TransformerFactory TRANS_FACTORY = TransformerFactory.newInstance(
            "net.sf.saxon.TransformerFactoryImpl", getClass().getClassLoader());

        TRANS_FACTORY.setURIResolver(new Pica2ModsURIResolver(this));
        try {
            Element picaRecord = retrievePicaXMLViaSRU(catalogKey, sruQuery);

            if (picaRecord != null) {
                Source xsl = new StreamSource(getClass().getClassLoader()
                    .getResourceAsStream(PICA2MODS_XSLT_PATH + xslFile));
                xsl.setSystemId(PICA2MODS_XSLT_PATH + xslFile);
                Transformer transformer = TRANS_FACTORY.newTransformer(xsl);

                transformer.setOutputProperty(OutputKeys.INDENT, "yes");
                transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "2");

                /*
                <xsl:param name="MCR.SRU.URL" select="'http://sru.k10plus.de'"/>
                <xsl:param name="MCR.UNAPI.URL" select="'http://unapi.k10plus.de'"/>
                <xsl:param name="MCR.PICA.DATABASE.k10plus" select="'k10plus'"/>
                <xsl:param name="MCR.MODS.DateEncoding" select="'w3cdtf'"/>
                <xsl:param name="CONVERTER_VERSION" select="'Pica2Mods 2.0'"/>
                */

                transformer.setParameter("WebApplicationBaseURL", mycoreBaseURL);
                transformer.transform(new DOMSource(picaRecord), result);
            }

        } catch (Exception e) {
            LOGGER.error("Error transforming XML", e);
        }
    }

    public static String outputXML(Node node) {
        // ein Stylesheet zur Identitätskopie ...
        String IDENTITAETS_XSLT = "<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='1.0'>"
            + "<xsl:template match='/'><xsl:copy-of select='.'/>" + "</xsl:template></xsl:stylesheet>";

        Source xmlSource = new DOMSource(node);
        Source xsltSource = new StreamSource(new StringReader(IDENTITAETS_XSLT));

        StringWriter sw = new StringWriter();
        Result ergebnis = new StreamResult(sw);

        TransformerFactory transFact = TransformerFactory.newInstance();

        try {
            Transformer trans = transFact.newTransformer(xsltSource);
            trans.transform(xmlSource, ergebnis);

        } catch (TransformerException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return sw.toString();
    }

    public String getPica2MODSVersion(String xslFile) throws Pica2ModsException {
        String version = "";
        try {
            DocumentBuilder dBuilder = DBF.newDocumentBuilder();
            Document doc = dBuilder.parse(
                getClass().getClassLoader().getResourceAsStream(PICA2MODS_XSLT_PATH + xslFile));
            NodeList nl = doc.getDocumentElement().getElementsByTagName("xsl:variable");

            for (int i = 0; i < nl.getLength(); i++) {
                if (nl.item(i).getAttributes().getNamedItem("name").getTextContent().equals("XSL_VERSION_PICA2MODS")) {
                    version = nl.item(i).getTextContent();
                    break;
                }
            }

        } catch (Exception e) {
            throw new Pica2ModsException("Error getting mods metadata: " + e.getMessage());
        }
        return version;
    }
}
