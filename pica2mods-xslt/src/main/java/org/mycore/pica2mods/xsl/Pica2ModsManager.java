package org.mycore.pica2mods.xsl;

import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.io.StringWriter;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Enumeration;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Objects;
import java.util.concurrent.TimeUnit;
import java.util.jar.Attributes;
import java.util.jar.Manifest;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.mycore.pica2mods.xsl.model.Pica2ModsConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class Pica2ModsManager {
    private static final Logger LOGGER = LoggerFactory.getLogger(Pica2ModsManager.class);

    public static final String PICA2MODS_XSLT_PATH = "xsl/";

    private static final String NS_PICA = "info:srw/schema/5/picaXML-v1.0";

    static final String XML_FEATURE__DISSALLOW_DOCTYPE_DECL = "http://apache.org/xml/features/disallow-doctype-decl";

    private static DocumentBuilderFactory DBF;

    static {
        DBF = DocumentBuilderFactory.newInstance();
        DBF.setNamespaceAware(true);
        try {
            DBF.setFeature(XML_FEATURE__DISSALLOW_DOCTYPE_DECL, true);
            DBF.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);
        } catch (ParserConfigurationException e) {
            // ignore
        }
    }

    private Pica2ModsConfig config = null;

    public Pica2ModsManager(Pica2ModsConfig config) {
        this.config = config;
    }

    public Pica2ModsConfig getConfig() {
        return config;
    }

    // http://sru.k10plus.de/opac-de-28?operation=searchRetrieve&maximumRecords=1&recordSchema=picaxml&query=pica.ppn%3D1023803275
    public Element retrievePicaXMLViaSRU(String catalogId, String sruQuery) throws Pica2ModsException {
        if (config.getCatalogs().get(catalogId) != null) {
            String theURL = config.getSruUrl() + config.getCatalogs().get(catalogId).getSruKey()
                + "?operation=searchRetrieve&maximumRecords=1&recordSchema=picaxml&query="
                + URLEncoder.encode(sruQuery, StandardCharsets.UTF_8);
            return retrievePicaXMLFromURL(theURL);
        }
        return null;
    }

    // https://unapi.k10plus.de/?&format=picaxml&id=opac-de-28:ppn:1662436106
    public Element retrievePicaXMLViaUnAPI(String catalogId, String ppn) throws Pica2ModsException {
        if (config.getCatalogs().get(catalogId) != null) {
            String unapiKey = config.getCatalogs().get(catalogId).getUnapiKey() + ":ppn:" + ppn;
            return retrievePicaXMLViaUnAPI(unapiKey);
        }
        return null;
    }

    // https://unapi.k10plus.de/?&format=picaxml&id=opac-de-28:ppn:1662436106
    public Element retrievePicaXMLViaUnAPI(String unapiKey) throws Pica2ModsException {
        String theURL = config.getUnapiUrl() + "?&format=picaxml&id=" + unapiKey;
        return retrievePicaXMLFromURL(theURL);
    }

    private Element retrievePicaXMLFromURL(String theURL) throws Pica2ModsException {
        Document document = retrieveWithRetryXMLFromURL(theURL);
        NodeList nl = document.getElementsByTagNameNS(NS_PICA, "record");
        if (nl.getLength() > 0) {
            return (Element) nl.item(0);
        } else {
            String msg = "No Record found for: " + theURL;
            throw new Pica2ModsException(msg);
        }
    }

    protected Document retrieveWithRetryXMLFromURL(String theURL) throws Pica2ModsException {
        if (!theURL.startsWith("http://") && !theURL.startsWith("https://")) {
            throw new IllegalArgumentException("The URL should start with 'http://' or 'https://'");
        }
        try {
            URL url = new URL(theURL);

            int loop = 0;
            Document document = null;
            do {
                loop++;
                LOGGER.debug("Getting catalogue data from: " + theURL);
                try (InputStream xmlStream = url.openStream()) {
                    DocumentBuilder dBuilder = DBF.newDocumentBuilder();
                    document = dBuilder.parse(xmlStream);
                } catch (Exception e) {
                    if (loop <= 2) {
                        LOGGER.error("An error occurred - waiting 5 min and try again", e);
                        TimeUnit.MINUTES.sleep(5);
                    } else {
                        String msg = "Could not retrieve Pica from URL: " + theURL;
                        throw new Pica2ModsException(msg, e);
                    }
                }
            } while (document == null && loop <= 2);
            if (document == null) {
                String msg = "Could not retrieve Pica from URL: " + theURL;
                throw new Pica2ModsException(msg, null);
            }
            return document;

        } catch (MalformedURLException mfe) {
            throw new Pica2ModsException("The SRU URL is wrong", mfe);
        } catch (InterruptedException ie) {
            throw new Pica2ModsException("An interrupted exception occurred", ie);
        }
    }

    public void createMODSDocumentViaSRU(String catalogId, String sruQuery, Result result,
        Map<String, String> parameter) throws Pica2ModsException {
        Element picaRecord = retrievePicaXMLViaSRU(catalogId, sruQuery);
        try {
            createMODSDocumentFromPicaXML(picaRecord, catalogId, result, parameter);
        } catch (TransformerException tfe) {
            throw new Pica2ModsException("Could not create MODS from PicaXML", tfe);
        }
    }

    public void createMODSDocumentViaUnAPI(String catalogId, String ppn, Result result, Map<String, String> parameter)
        throws Pica2ModsException {
        Element picaRecord = retrievePicaXMLViaUnAPI(catalogId, ppn);
        try {
            createMODSDocumentFromPicaXML(picaRecord, catalogId, result, parameter);
        } catch (TransformerException tfe) {
            throw new Pica2ModsException("Could not create MODS from PicaXML", tfe);
        }
    }

    private void createMODSDocumentFromPicaXML(Element picaRecord, String catalogId, Result result,
        Map<String, String> parameter) throws TransformerException {
        // uses the configured Transformer-Factory (e.g. XALAN, if installed)
        // TransformerFactory TRANS_FACTORY = TransformerFactory.newInstance();
        // Java 9 provides a method newDefaultInstance() to retrieve the
        // built-in system default implementation

        //for Saxon we set the class name explicitly
        TransformerFactory TRANS_FACTORY = TransformerFactory.newInstance(
            "net.sf.saxon.TransformerFactoryImpl", getClass().getClassLoader());

        TRANS_FACTORY.setURIResolver(new Pica2ModsXSLTURIResolver(this));
        TRANS_FACTORY.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);

        if (picaRecord != null) {
            Source xsl = new StreamSource(getClass().getClassLoader()
                .getResourceAsStream(PICA2MODS_XSLT_PATH + getConfig().getCatalog(catalogId).getXsl()));
            xsl.setSystemId(PICA2MODS_XSLT_PATH + getConfig().getCatalog(catalogId).getXsl());
            Transformer transformer = TRANS_FACTORY.newTransformer(xsl);

            transformer.setOutputProperty(OutputKeys.INDENT, "yes");
            transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "2");

            /*
                <xsl:param name="MCR.PICA2MODS.SRU.URL" select="'https://sru.k10plus.de'" />
                <xsl:param name="MCR.PICA2MODS.UNAPI.URL" select="'https://unapi.k10plus.de'" />
                <xsl:param name="MCR.PICA2MODS.DATABASE" select="'k10plus'"/>
                <xsl:param name="MCR.PICA2MODS.CONVERTER_VERSION" select="'Pica2Mods 2.3'"/>
             */

            if (config.getMycoreUrl() != null) {
                transformer.setParameter("WebApplicationBaseURL", config.getMycoreUrl());
            }
            for (Entry<String, String> e : parameter.entrySet()) {
                transformer.setParameter(e.getKey(), e.getValue());
            }
            transformer.transform(new DOMSource(picaRecord), result);
        }
    }

    public static String outputXML(Node node) throws Pica2ModsException {
        // ein Stylesheet zur Identitätskopie ...
        String IDENTITAETS_XSLT = """
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
              <xsl:template match="@*|node()">
                <xsl:copy>
            	  <xsl:apply-templates select="@*|node()" />
            	</xsl:copy>
              </xsl:template>
            </xsl:stylesheet>
            """;

        Source xmlSource = new DOMSource(node);
        Source xsltSource = new StreamSource(new StringReader(IDENTITAETS_XSLT));

        StringWriter sw = new StringWriter();
        Result ergebnis = new StreamResult(sw);

        try {
            TransformerFactory transFact = TransformerFactory.newInstance();
            transFact.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);
            Transformer trans = transFact.newTransformer(xsltSource);
            trans.transform(xmlSource, ergebnis);

        } catch (TransformerException e) {
            throw new Pica2ModsException("Could not output XML", e);
        }
        return sw.toString();
    }

    // does not work when application was started inside Eclipse
    public static String retrieveBuildInfosFromManifest(boolean addCommitInfos) {

        Enumeration<URL> resources;
        try {
            resources = Pica2ModsManager.class.getClassLoader().getResources("META-INF/MANIFEST.MF");
            while (resources.hasMoreElements()) {
                URL url = resources.nextElement();

                Manifest manifest = new Manifest(url.openStream());
                Attributes attributes = manifest.getMainAttributes();
                if (Objects.equals(attributes.getValue("Implementation-Artifact-ID"), "pica2mods-xslt")) {
                    StringBuilder sb = new StringBuilder();
                    sb.append(attributes.getValue("Implementation-Title")).append(" ")
                        .append(attributes.getValue("Implementation-Version"));
                    if (addCommitInfos) {
                        sb.append(" [SCM: \"").append(attributes.getValue("SCM-Branch")).append("\" \"")
                            .append(attributes.getValue("SCM-Commit"))
                            .append("\" \"" + attributes.getValue("SCM-Time")).append("\"]");
                    }
                    return sb.toString();
                }
            }
        } catch (IOException e) {
            LOGGER.error("Unable to read manifest entry", e);
            // do not rethrow exception, but use default value
        }
        return "Pica2MODS";
    }

}
