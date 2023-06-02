package org.mycore.pica2mods.mods2solr;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayDeque;
import java.util.Deque;

import javax.xml.namespace.QName;
import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.events.Attribute;
import javax.xml.stream.events.XMLEvent;

import org.mycore.pica2mods.mods2solr.util.JSONValue;
import org.slf4j.LoggerFactory;
import org.springframework.util.StringUtils;

public class MODSProcessor {
    private static String NS_MODS = "http://www.loc.gov/mods/v3";

    private static XMLInputFactory XML_INPUT_FACTORY = XMLInputFactory.newInstance();

    private static QName QN_MODS_ELEM = new QName(NS_MODS, "mods", "mods");

    private static QName QN_MYCORE_MODSCONTAINER = new QName("modsContainer");

    static {
        XML_INPUT_FACTORY.setProperty(XMLInputFactory.IS_SUPPORTING_EXTERNAL_ENTITIES, false);
    }

    public String process(String id, InputStream is) {
        StringBuilder jsonResult = new StringBuilder("[");
        Deque<String> elementStack = new ArrayDeque<String>();

        boolean filterItem = false;
        boolean inMODS = false;
        String modsContainerType = null;
        try {
            Reader fileReader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
            XMLEventReader xmlEventReader = XML_INPUT_FACTORY.createXMLEventReader(fileReader);
            while (xmlEventReader.hasNext()) {
                XMLEvent xmlEvent = xmlEventReader.nextEvent();
                if (xmlEvent.isStartElement()) {
                    if (xmlEvent.asStartElement().getName().equals(QN_MYCORE_MODSCONTAINER)) {
                        Attribute a = xmlEvent.asStartElement().getAttributeByName(new QName("type"));
                        modsContainerType = (a == null) ? null : a.getValue();
                    }
                    if (xmlEvent.asStartElement().getName().equals(QN_MODS_ELEM)) {
                        inMODS = true;
                        filterItem = false;
                        elementStack.clear();
                        if (jsonResult.charAt(jsonResult.length() - 1) != '[') {
                            jsonResult.append(",\n");
                        }
                        jsonResult.append("{");

                    }

                    if (xmlEvent.asStartElement().getName().getNamespaceURI().equals(NS_MODS) && inMODS) {
                        elementStack.add(xmlEvent.asStartElement().getName().getLocalPart());
                        xmlEvent.asStartElement().getAttributes().forEachRemaining(a -> {
                            String attributeName = a.getName().getLocalPart();
                            if (StringUtils.hasText(a.getName().getPrefix())) {
                                attributeName = a.getName().getPrefix() + "_" + attributeName;
                            }
                            String fieldName = String.join("__", elementStack) + "_@" + attributeName;
                            jsonResult.append("\"" + fieldName + "\":\"" + JSONValue.escape(a.getValue()) + "\",");
                        });

                    }
                }
                if (xmlEvent.isCharacters() && inMODS) {
                    String fieldName = String.join("__", elementStack);

                    String value = xmlEvent.asCharacters().getData().trim();
                    if (value.length() > 200) {
                        value = value.substring(0, 200) + "…";
                    }

                    if (!filterItem && value.length() > 0) {
                        jsonResult.append("\"" + fieldName + "\":\"" + JSONValue.escape(value) + "\",");

                    }

                }

                if (xmlEvent.isEndElement()) {
                    if (xmlEvent.asEndElement().getName().getNamespaceURI().equals(NS_MODS) && inMODS) {
                        elementStack.removeLast();
                    }
                    if (xmlEvent.asEndElement().getName().equals(QN_MODS_ELEM)) {
                        if (modsContainerType != null
                            && !modsContainerType.equals("imported")
                            && !modsContainerType.equals("generated")) {
                            id = id + "_" + modsContainerType;
                        }
                        jsonResult.append("\"id\":\"" + id + "\"");
                        jsonResult.append("}");
                        inMODS = false;
                    }
                    if (xmlEvent.asEndElement().getName().equals(QN_MYCORE_MODSCONTAINER)) {
                        modsContainerType = null;
                    }
                }
            }
        } catch (Exception e) {
            LoggerFactory.getLogger(MODSProcessor.class).error("MODS processing failed.", e);
        }

        jsonResult.append("]");

        return jsonResult.toString();
    }

}
