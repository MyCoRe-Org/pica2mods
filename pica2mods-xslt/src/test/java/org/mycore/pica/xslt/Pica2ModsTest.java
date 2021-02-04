package org.mycore.pica.xslt;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.jdom2.input.SAXBuilder;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.jdom2.transform.JDOMResult;
import org.jdom2.transform.JDOMSource;
import org.junit.Test;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Pica2ModsTest {

    private static final String HTTP_PROTOCOL = "http://";

    private static final String HTTPS_PROTOCOL = "https://";

    private static final XMLOutputter XML_OUTPUTTER = new XMLOutputter(Format.getPrettyFormat());

    private final List<String> epubPPNList = Stream.of("1744582424", "1744413819", "174427830X", "1048638243")
        .collect(Collectors.toList());

    private final List<String> rdaPPNList = Stream.of("1042506914").collect(Collectors.toList());

    private final List<String> kxpPPNList = Stream.of("1703157931", "1672263514", "873996445", "812707060")
        .collect(Collectors.toList());

    private final List<String> topLevelElements = Stream
        .of("genre", "typeofResource", "titleInfo", "nonSort", "subTitle", "title",
            "partNumber", "partName", "name", "namePart", "displayForm", "role", "affiliation", "originInfo", "place",
            "publisher", "dateIssued", "dateCreated", "dateModified", "dateValid", "dateOther", "edition", "issuance",
            "frequency", "relatedItem", "language", "physicalDescription", "abstract", "note", "subject",
            "classification", "location", "shelfLocator", "url", "accessCondition", "part", "extension",
            "recordInfo")
        .collect(Collectors.toList());

    private static final String MODS_URL = "http://www.loc.gov/mods/v3";

    public static final Namespace MODS_NAMESPACE = Namespace.getNamespace("mods", MODS_URL);

    private final String URL_BASE = "http://unapi.k10plus.de/?&format=picaxml&id=k10plus:ppn:";

    private final SAXBuilder saxBuilder = new SAXBuilder();

    private final XMLOutputter XML_OUT = new XMLOutputter(Format.getPrettyFormat());

    @Test
    public void testConvert() throws TransformerException, IOException {
        List<Tripple<String, Document, Document>> triList = new ArrayList<>();

        epubPPNList.stream().map(ppn -> createTri(ppn, "epub")).forEach(triList::add);
        rdaPPNList.stream().map(ppn -> createTri(ppn, "rda")).forEach(triList::add);
        kxpPPNList.stream().map(ppn -> createTri(ppn, "kxp")).forEach(triList::add);

        final Document result = buildResultDocument(triList);

        try (InputStream stylesheetStream = getClass().getClassLoader().getResourceAsStream("resultTransformer.xsl")) {
            final StreamSource source = new StreamSource(stylesheetStream);
            final Transformer transformer = getTFactory().newTransformer(source);
            transformer.transform(new JDOMSource(result), new StreamResult(new File("result.html")));
        }
    }

    private Tripple<String, Document, Document> createTri(String ppn, String type) {
        final Tripple<String, Document, Document> tri = new Tripple<>();
        tri.setO1(type+":"+ppn);
        tri.setO2(resolveAndConvert(ppn));
        tri.setO3(readTestDocument(ppn, type));
        return tri;
    }

    private Document buildResultDocument(List<Tripple<String, Document, Document>> result) {
        final Element root = new Element("result");
        Document resultDocument = new Document(root);

        result.forEach(tri -> {
            root.addContent(buildResultPart(tri));
        });

        return resultDocument;
    }

    private Element buildResultPart(Tripple<String, Document, Document> tri) {
        final String ppn = tri.getO1();
        final Document transformed = tri.getO2();
        final Document expected = tri.getO3();

        Element compare = new Element("compare");
        compare.setAttribute("ppn", ppn);

        topLevelElements.stream().forEach(tle -> {
            final List<Element> tleTransformed = transformed.getRootElement().getChildren(tle, MODS_NAMESPACE);
            final List<Element> tleExpected = expected.getRootElement().getChildren(tle, MODS_NAMESPACE);

            Element tleElement = new Element("tle");
            tleElement.setAttribute("name", tle);

            if (tleTransformed.size() > 0 || tleExpected.size() > 0) {
                Element transformedElement = new Element("transformed");
                transformedElement.setText(deleteXMLNS(XML_OUT.outputString(tleTransformed)));
                tleElement.addContent(transformedElement);

                Element expectedElement = new Element("expected");
                expectedElement.setText(deleteXMLNS(XML_OUT.outputString(tleExpected)));
                tleElement.addContent(expectedElement);

                compare.addContent(tleElement);
            }
        });

        return compare;
    }

    private Document readTestDocument(String ppn, String type) {
        try (InputStream docIs = getClass().getClassLoader()
            .getResourceAsStream("testFiles/" + type + "/" + ppn + ".xml")) {
            return saxBuilder.build(docIs);
        } catch (IOException | JDOMException e) {
            throw new RuntimeException("Error while reading test document", e);
        }
    }

    private Document resolveAndConvert(String ppn) {
        System.out.println("Transforming " + ppn);

        try (InputStream styleIS = getClass().getClassLoader().getResourceAsStream("xsl/pica2mods.xsl")) {
            final URL url = new URL(URL_BASE + ppn);
            try (InputStream picaIS = url.openStream()) {
                final Document jdom = saxBuilder.build(picaIS);

                final StreamSource streamSource = new StreamSource(styleIS);
                final Transformer transformer = getTFactory().newTransformer(streamSource);
                final JDOMResult jdomResult = new JDOMResult();

                transformer.transform(new JDOMSource(jdom), jdomResult);

                return jdomResult.getDocument();
            } catch (IOException | JDOMException | TransformerException e) {
                throw new RuntimeException("Error while resolving", e);
            }
        } catch (IOException e) {
            throw new RuntimeException("Error while reading Stylesheet", e);

        }
    }

    private TransformerFactory getTFactory() {
        final TransformerFactory transformerFactory = TransformerFactory
            .newInstance("net.sf.saxon.TransformerFactoryImpl", ClassLoader.getSystemClassLoader());
        transformerFactory.setURIResolver((v1, v2) -> {
            System.out.println("Resolve " + v1);
            if (!v1.contains(":")) {
                return new StreamSource(getClass().getClassLoader().getResourceAsStream("xsl/" + v1));
            } else {
                if (v1.startsWith(HTTP_PROTOCOL) || v1.startsWith(HTTPS_PROTOCOL)) {
                    try {
                        return new StreamSource(new URL(v1).openStream());
                    } catch (IOException e) {
                        e.printStackTrace();
                        return null;
                    }
                }
                return null;
            }
        });
        return transformerFactory;
    }

    private String deleteXMLNS(String text){
        return text.replace(" xmlns:mods=\"http://www.loc.gov/mods/v3\"","")
                .replace(" xmlns:p=\"info:srw/schema/5/picaXML-v1.0\"","")
        .replace(" xmlns:xlink=\"http://www.w3.org/1999/xlink\"","");

    }

    private static class Tripple<T1, T2, T3> {
        private T1 o1;

        private T2 o2;

        private T3 o3;

        public Tripple(T1 o1, T2 o2, T3 o3) {
            this.o1 = o1;
            this.o2 = o2;
            this.o3 = o3;
        }

        public Tripple() {

        }

        public T1 getO1() {
            return o1;
        }

        public void setO1(T1 o1) {
            this.o1 = o1;
        }

        public T2 getO2() {
            return o2;
        }

        public void setO2(T2 o2) {
            this.o2 = o2;
        }

        public T3 getO3() {
            return o3;
        }

        public void setO3(T3 o3) {
            this.o3 = o3;
        }
    }
}
