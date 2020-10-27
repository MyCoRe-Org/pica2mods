package org.mycore.pica2mods.util;

import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.xml.sax.EntityResolver;
import org.xml.sax.ErrorHandler;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

public class XMLSchemaValidator {
    static final String JAXP_SCHEMA_LANGUAGE = "http://java.sun.com/xml/jaxp/properties/schemaLanguage";

    static final String JAXP_SCHEMA_SOURCE = "http://java.sun.com/xml/jaxp/properties/schemaSource";

    static final String W3C_XML_SCHEMA = "http://www.w3.org/2001/XMLSchema";

    /*
    static final String DEFAULT_METS_SCHEMA_LOCATIONS = "http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd"
            + " http://www.w3.org/1999/xlink http://www.loc.gov/standards/xlink/xlink.xsd"
            + " http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-6.xsd"
            + " http://www.loc.gov/mix/v20 http://www.loc.gov/standards/mix/mix20/mix20.xsd"
            + " http://purl.uni-rostock.de/ub/standards/mets-extended-v1.0 http://purl.uni-rostock.de/ub/standards/mets-extended-v1.0.xsd"
            + " http://purl.uni-rostock.de/ub/standards/mets-extended-v1.1 http://purl.uni-rostock.de/ub/standards/mets-extended-v1.1.xsd"
            + " http://dfg-viewer.de/ http://purl.uni-rostock.de/ub/standards/dfg-viewer.xsd"
            + " info:srw/schema/5/picaXML-v1.0 http://www.loc.gov/standards/sru/recordSchemas/pica-xml-v1-0.xsd";
    */
    static final String DEFAULT_METS_SCHEMA_LOCATIONS = "http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-6.xsd";

    private DocumentBuilderFactory DOC_BUILDER_FACTORY = DocumentBuilderFactory.newInstance();

    private boolean isValid = true;

    private String errorMsg = "";

    public XMLSchemaValidator() {
        init(DEFAULT_METS_SCHEMA_LOCATIONS);
    }

    public XMLSchemaValidator(String schemaLocations) {
        init(schemaLocations);
    }

    private void init(String SchemaLocations) {
        List<String> schemas = new ArrayList<>();
        for (String s : SchemaLocations.split("\\s")) {
            s = s.trim();
            if (s.toLowerCase().endsWith(".xsd")) {
                schemas.add(s);
            }
        }

        DOC_BUILDER_FACTORY.setNamespaceAware(true);
        DOC_BUILDER_FACTORY.setValidating(true);

        try {
            DOC_BUILDER_FACTORY.setAttribute(JAXP_SCHEMA_LANGUAGE, W3C_XML_SCHEMA);
            DOC_BUILDER_FACTORY.setAttribute(JAXP_SCHEMA_SOURCE, schemas.toArray(new String[] {}));

        } catch (IllegalArgumentException x) {
            // Happens if the parser does not support JAXP 1.2
        }

    }

    public boolean validate(String xmlContent) {
        try {
            DocumentBuilder docBuilder = DOC_BUILDER_FACTORY.newDocumentBuilder();
            docBuilder.setErrorHandler(new ErrorHandler() {

                @Override
                public void warning(SAXParseException exception) throws SAXException {
                    outputError(exception);
                }

                @Override
                public void fatalError(SAXParseException exception) throws SAXException {
                    outputError(exception);
                }

                @Override
                public void error(SAXParseException exception) throws SAXException {
                    outputError(exception);
                }

                private void outputError(SAXParseException exception) throws SAXException {
                    String msg = "Line: " + exception.getLineNumber() + ", Column: " + exception.getColumnNumber()
                        + " - " + exception.getMessage();
                    errorMsg += "\n" + msg;
                    System.err.println(msg);
                    isValid = false;
                }
            });
            docBuilder.setEntityResolver(new EntityResolver() {

                @Override
                public InputSource resolveEntity(String publicId, String systemId) throws SAXException, IOException {
                    try {
                        InputStream is = getClass()
                            .getResourceAsStream("/xml_schemas/" + systemId.substring(systemId.lastIndexOf("/") + 1));
                        if (is != null) {
                            return new InputSource(is);
                        }
                    } catch (Exception e) {
                        System.err.println("Error resolving entity: " + e.getMessage());
                        e.printStackTrace();
                    }
                    return null;
                }
            });

            docBuilder.parse(new InputSource(new StringReader(xmlContent)));
        } catch (Exception e) {
            e.printStackTrace();
        }

        return isValid;
    }

    public String getErrorMsg() {
        return errorMsg;
    }
}
