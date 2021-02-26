package org.mycore.pica.xslt;

import org.jdom2.Attribute;
import org.jdom2.Comment;
import org.jdom2.Content;
import org.jdom2.DocType;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.jdom2.ProcessingInstruction;
import org.jdom2.Text;
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
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Pica2ModsTest {

    private static final String HTTP_PROTOCOL = "http://";

    private static final String HTTPS_PROTOCOL = "https://";

    private final List<PicaTest> TESTS = Stream.of(
        new PicaTest("1744582424", "default", "titleInfo"),
        new PicaTest("1729046428", "default", "identifier"),
        new PicaTest("1729046428", "default", "abstract"),
        new PicaTest("1729046428", "default", "name")
    )
        .collect(Collectors.toList());
    private static final String MODS_URL = "http://www.loc.gov/mods/v3";

    public static final Namespace MODS_NAMESPACE = Namespace.getNamespace("mods", MODS_URL);

    private final String URL_BASE = "http://unapi.k10plus.de/?&format=picaxml&id=k10plus:ppn:";

    private final SAXBuilder saxBuilder = new SAXBuilder();

    private final XMLOutputter XML_OUT = new XMLOutputter(Format.getPrettyFormat());

    @Test
    public void testConvert() throws TransformerException, IOException {
        List<PicaTestResult> resultList = new ArrayList<>();
        for (PicaTest test : TESTS) {
            resultList.add(runTest(test));
        }

        final Document result = buildResultDocument(resultList);

        try (InputStream stylesheetStream = getClass().getClassLoader().getResourceAsStream("resultTransformer.xsl")) {
            final StreamSource source = new StreamSource(stylesheetStream);
            final Transformer transformer = getTFactory().newTransformer(source);
            transformer.transform(new JDOMSource(result), new StreamResult(new File("result.html")));
        }
    }

    private PicaTestResult runTest(PicaTest test) {
        Document result = resolveAndConvert(test);
        Document expected = readTestDocument(test.getPpn(), test.getType());

        final Element resultChild = result.getRootElement().getChild(test.getTopLevelElement(), MODS_NAMESPACE);
        final Element exptectedChild = expected.getRootElement().getChild(test.getTopLevelElement(), MODS_NAMESPACE);

        final PicaTestResult testResult = new PicaTestResult(test, result, expected);

        final JDOMEquivalent jdomEquivalent = new JDOMEquivalent();
        testResult.setFailed(!jdomEquivalent.equivalent(resultChild,exptectedChild));
        testResult.setReasonList(jdomEquivalent.getReasonList());
        return testResult;
    }

    private Document buildResultDocument(List<PicaTestResult> resultList) {
        final Element root = new Element("result");
        Document resultDocument = new Document(root);

        resultList.forEach(result -> {
            root.addContent(buildResultDocumentPart(result));
        });

        return resultDocument;
    }

    private Element buildResultDocumentPart(PicaTestResult result) {
        final PicaTest test = result.getTest();
        final Document transformed = result.getResult();
        final Document expected = result.getExpected();

        Element compare = new Element("compare");
        compare.setAttribute("ppn", test.getPpn());

        String tle = result.getTest().getTopLevelElement();
        final List<Element> tleTransformed = transformed.getRootElement().getChildren(tle, MODS_NAMESPACE);
        final List<Element> tleExpected = expected.getRootElement().getChildren(tle, MODS_NAMESPACE);

        compare.setAttribute("name", tle);
        compare.setAttribute("failed", String.valueOf(result.isFailed()));
        if(result.isFailed()){
            Element reason = new Element("reason");
            reason.setText(result.getReasonList().stream().collect(Collectors.joining("\n")));
            compare.addContent(reason);
        }
        if (tleTransformed.size() > 0 || tleExpected.size() > 0) {
            Element transformedElement = new Element("transformed");
            transformedElement.setText(deleteXMLNS(XML_OUT.outputString(tleTransformed)));
            compare.addContent(transformedElement);

            Element expectedElement = new Element("expected");
            expectedElement.setText(deleteXMLNS(XML_OUT.outputString(tleExpected)));
            compare.addContent(expectedElement);
        }

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

    private Document resolveAndConvert(PicaTest test) {
        String ppn = test.getPpn();
        String stylePath = "xsl/" + test.getType() + "/pica2mods-" + test.getType() + "-" + test.getTopLevelElement()
            + ".xsl";
        System.out.println("Transforming " + ppn + " with " + stylePath);
        System.setProperty("XSL_TESTING","true");

        try (InputStream styleIS = getClass().getClassLoader().getResourceAsStream(stylePath)) {
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

    private static class PicaTest {
        public PicaTest(String ppn, String type, String topLevelElement) {
            this.ppn = ppn;
            this.type = type;
            this.topLevelElement = topLevelElement;
        }

        private String ppn;

        private String type;

        private String topLevelElement;

        public String getPpn() {
            return ppn;
        }

        public void setPpn(String ppn) {
            this.ppn = ppn;
        }

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }

        public String getTopLevelElement() {
            return topLevelElement;
        }

        public void setTopLevelElement(String topLevelElement) {
            this.topLevelElement = topLevelElement;
        }
    }

    private static class PicaTestResult {

        public PicaTestResult(PicaTest test, Document result, Document expected) {
            this.test = test;
            this.result = result;
            this.expected = expected;
        }

        public PicaTest getTest() {
            return test;
        }

        public void setTest(PicaTest test) {
            this.test = test;
        }

        public Document getResult() {
            return result;
        }

        public void setResult(Document result) {
            this.result = result;
        }

        public Document getExpected() {
            return expected;
        }

        public void setExpected(Document expected) {
            this.expected = expected;
        }

        public boolean isFailed() {
            return failed;
        }

        public void setFailed(boolean failed) {
            this.failed = failed;
        }

        private PicaTest test;

        private Document result;

        private Document expected;

        private boolean failed;

        private List<String> reasonList;

        public void setReasonList(List<String> reasonList) {
            this.reasonList = reasonList;
        }

        public List<String> getReasonList() {
            return reasonList;
        }
    }

    private static class JDOMEquivalent {

        private JDOMEquivalent() {
            reasonList = new ArrayList<>();
        }

        private List<String> reasonList;

        public List<String> getReasonList() {
            return reasonList;
        }

        public boolean equivalent(Element e1, Element e2) {
            return equivalentName(e1, e2) && equivalentAttributes(e1, e2)
                    && equivalentContent(clean(e1.getContent()), clean(e2.getContent()));
        }

        public List<Content> clean(List<Content> cl){
            return cl.stream().filter(c-> {
                if(c instanceof Text){
                    return ((Text) c).getText().trim().replace("\n","").length()>0;
                }
                    return true;

            }).collect(Collectors.toList());
        }

        public boolean equivalent(Text t1, Text t2) {
            String v1 = t1.getValue();
            String v2 = t2.getValue();
            boolean equals = v1.equals(v2);
            if (!equals) {
                reasonList.add("Text differs \""+t1+"\"!=\""+t2+"\"");
            }
            return equals;
        }

        public boolean equivalent(DocType d1, DocType d2) {
            boolean equals = d1.getPublicID().equals(d2.getPublicID()) && d1.getSystemID().equals(d2.getSystemID());
            if (!equals) {
                reasonList.add("DocType differs \""+d1+"\"!=\""+d2+"\"");
            }
            return equals;
        }

        public boolean equivalent(Comment c1, Comment c2) {
            String v1 = c1.getValue();
            String v2 = c2.getValue();
            boolean equals = v1.equals(v2);
            if (!equals) {
                reasonList.add("Comment differs \""+c1+"\"!=\""+c2+"\"");
            }
            return equals;
        }

        public boolean equivalent(ProcessingInstruction p1, ProcessingInstruction p2) {
            String t1 = p1.getTarget();
            String t2 = p2.getTarget();
            String d1 = p1.getData();
            String d2 = p2.getData();
            boolean equals = t1.equals(t2) && d1.equals(d2);
            if (!equals) {
                reasonList.add("ProcessingInstruction differs \""+p1+"\"!=\""+p2+"\"");
            }
            return equals;
        }

        public boolean equivalentAttributes(Element e1, Element e2) {
            List<Attribute> aList1 = e1.getAttributes();
            List<Attribute> aList2 = e2.getAttributes();
            if (aList1.size() != aList2.size()) {
                reasonList.add("Number of attributes differ \""+aList1+"\"!=\""+aList2+"\" for element " + e1.getName());
                return false;
            }
            HashSet<String> orig = new HashSet<>(aList1.size());
            for (Attribute attr : aList1) {
                orig.add(attr.toString());
            }
            for (Attribute attr : aList2) {
                orig.remove(attr.toString());
            }
            if (!orig.isEmpty()){
                reasonList.add("Attributes differ \""+aList1+"\"!=\""+aList1+"\"");
            }

            return orig.isEmpty();
        }

        public boolean equivalentContent(List<Content> l1, List<Content> l2) {
            if (l1.size() != l2.size()) {
                reasonList.add("Number of content list elements differ "+l1.size()+"!="+l2.size());
                return false;
            }
            boolean result = true;
            Iterator<Content> i1 = l1.iterator();
            Iterator<Content> i2 = l2.iterator();
            while (result && i1.hasNext() && i2.hasNext()) {
                Object o1 = i1.next();
                Object o2 = i2.next();
                if (o1 instanceof Element && o2 instanceof Element) {
                    result = equivalent((Element) o1, (Element) o2);
                } else if (o1 instanceof Text && o2 instanceof Text) {
                    result = equivalent((Text) o1, (Text) o2);
                } else if (o1 instanceof Comment && o2 instanceof Comment) {
                    result = equivalent((Comment) o1, (Comment) o2);
                } else if (o1 instanceof ProcessingInstruction && o2 instanceof ProcessingInstruction) {
                    result = equivalent((ProcessingInstruction) o1, (ProcessingInstruction) o2);
                } else if (o1 instanceof DocType && o2 instanceof DocType) {
                    result = equivalent((DocType) o1, (DocType) o2);
                } else {
                    result = false;
                }
            }
            return result;
        }

        public boolean equivalentName(Element e1, Element e2) {
            Namespace ns1 = e1.getNamespace();
            String localName1 = e1.getName();

            Namespace ns2 = e2.getNamespace();
            String localName2 = e2.getName();

            return ns1.equals(ns2) && localName1.equals(localName2);
        }
    }



}
