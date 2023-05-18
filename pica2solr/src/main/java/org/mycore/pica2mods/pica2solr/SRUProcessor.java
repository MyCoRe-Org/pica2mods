package org.mycore.pica2mods.pica2solr;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.StandardCharsets;

import javax.xml.namespace.QName;
import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.events.XMLEvent;

import org.slf4j.LoggerFactory;

public class SRUProcessor {
    private static String NS_PICA = "info:srw/schema/5/picaXML-v1.0";

    @SuppressWarnings("unused")
    private static String NS_SRU = "http://docs.oasis-open.org/ns/search-ws/sruResponse";

    private static XMLInputFactory XML_INPUT_FACTORY = XMLInputFactory.newInstance();

    private static QName QN_PICA_RECORD = new QName(NS_PICA, "record");

    private static QName QN_PICA_DATAFIELD = new QName(NS_PICA, "datafield");

    private static QName QN_PICA_SUBFIELD = new QName(NS_PICA, "subfield");

    private static QName QN_ATTR_TAG = new QName("tag");

    private static QName QN_ATTR_OCC = new QName("occurrence");

    private static QName QN_ATTR_CODE = new QName("code");

    public String process(InputStream is, String filterItemsByLibraryId) {
        StringBuilder jsonResult = new StringBuilder("[");
        String currentDataField = null;
        @SuppressWarnings("unused")
        String currentOccurence = null;
        String currentSubfield = null;
        String currentPPN = null;
        boolean filterItem = false;
        try {
            Reader fileReader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
            XMLEventReader xmlEventReader = XML_INPUT_FACTORY.createXMLEventReader(fileReader);
            while (xmlEventReader.hasNext()) {
                XMLEvent xmlEvent = xmlEventReader.nextEvent();
                if (xmlEvent.isStartElement()) {
                    if (xmlEvent.asStartElement().getName().equals(QN_PICA_RECORD)) {
                        filterItem = false;
                        currentPPN = null;
                        if (jsonResult.charAt(jsonResult.length() - 1) != '[') {
                            jsonResult.append(",\n");
                        }
                        jsonResult.append("{");

                    }

                    if (xmlEvent.asStartElement().getName().equals(QN_PICA_DATAFIELD)) {
                        currentDataField = xmlEvent.asStartElement().getAttributeByName(QN_ATTR_TAG).getValue();
                        currentOccurence = xmlEvent.asStartElement().getAttributeByName(QN_ATTR_OCC) == null ? null
                            : xmlEvent.asStartElement().getAttributeByName(QN_ATTR_OCC).getValue();
                    }
                    if (xmlEvent.asStartElement().getName().equals(QN_PICA_SUBFIELD)) {
                        currentSubfield = xmlEvent.asStartElement().getAttributeByName(QN_ATTR_CODE).getValue();
                    }
                }
                if (xmlEvent.isCharacters()) {
                    if (currentDataField != null && currentSubfield != null) {
                        /*
                         * //withOccurrence: //String fieldName = "df_" + currentDataField +
                         * (currentOccurence == null ? "" : "__oc_" + currentOccurence) + "__sf_" +
                         * currentSubfield; //without Occurrence: String fieldName = "df_" +
                         * currentDataField + "__sf_" + currentSubfield;
                         */
                        // withOccurrence:
                        // String fieldName = "p_" + currentDataField + (currentOccurence == null ? "" :
                        // "_o" + currentOccurence) + "_" + currentSubfield;
                        // without Occurrence:
                        String fieldName = "p_" + currentDataField + "_" + currentSubfield;

                        String value = xmlEvent.asCharacters().getData().trim();
                        if (value.length() > 200) {
                            value = value.substring(0, 200) + "…";
                        }
                        if (currentDataField.equals("003@") && currentSubfield.equals("0")) {
                            currentPPN = value;
                        }
                        if (currentDataField.equals("101@") && currentSubfield.equals("a")) {
                            filterItem = filterItemsByLibraryId != null && !value.equals(filterItemsByLibraryId);
                        }

                        if (!filterItem) {
                            jsonResult.append("\"" + fieldName + "\":\"" + JSONValue.escape(value) + "\",");

                        }
                    }
                }

                if (xmlEvent.isEndElement()) {
                    if (xmlEvent.asEndElement().getName().equals(QN_PICA_SUBFIELD)) {
                        currentSubfield = null;
                    }
                    if (xmlEvent.asEndElement().getName().equals(QN_PICA_DATAFIELD)) {
                        currentDataField = null;
                    }
                    if (xmlEvent.asEndElement().getName().equals(QN_PICA_RECORD)) {
                        jsonResult.append("\"id\":\"ppn_" + currentPPN + "\"");
                        jsonResult.append("}");

                    }
                }
            }
        } catch (Exception e) {
            LoggerFactory.getLogger(SRUProcessor.class).error("SRU processing failed.", e);
        }

        jsonResult.append("]");

        return jsonResult.toString();
    }

}
