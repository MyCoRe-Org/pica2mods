package org.mycore.pica2mods.xsl;

import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.MalformedURLException;
import java.net.URL;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Element;

public class Pica2ModsXSLTURIResolver implements URIResolver {
    private final Logger LOGGER = LoggerFactory.getLogger(Pica2ModsXSLTURIResolver.class);

    private Pica2ModsManager manager;

    public Pica2ModsXSLTURIResolver(Pica2ModsManager manager) {
        this.manager = manager;
    }

    @Override
    public Source resolve(String href, String base) throws TransformerException {
        //default: resolve internet sources
        if (href.startsWith("http:") || href.startsWith("https:")) {
            if (href.startsWith("https://unapi.k10plus.de?") || href.startsWith("https://sru.k10plus.de?")) {
                try {
                    return new DOMSource(manager.retrieveWithRetryXMLFromURL(href).getDocumentElement());
                } catch (Pica2ModsException e) {
                    throw new TransformerException("Could not read from URL: + href", e);
                }
            } else {
                try {
                    URL url = new URL(href);
                    return new StreamSource(url.openStream());
                } catch (MalformedURLException e) {
                    throw new TransformerException("Malformed URL", e);
                } catch (IOException e) {
                    throw new TransformerException("Error opening URL: ", e);
                }
            }
        }

        //read resource from classpath
        if (href.startsWith("resource:")) {
            String path = href.substring("resource:".length());
            InputStream is = getClass().getClassLoader()
                .getResourceAsStream(path);
            return new StreamSource(is);
        }

        if (href.startsWith("sru-gvk:")) {
            String query = href.substring("sru-gvk:".length());
            try {
                Element el = manager.retrievePicaXMLViaSRU("gvk", query);
                return new DOMSource(el);
            } catch (Exception e) {
                throw new TransformerException("Error processing SRU Query" + href, e);
            }
        }
        if (href.startsWith("sru-k10plus:")) {
            String query = href.substring("sru-k10plus:".length());
            try {
                Element el = manager.retrievePicaXMLViaSRU("k10plus", query);
                return new DOMSource(el);
            } catch (Exception e) {
                throw new TransformerException("Error processing SRU Query: " + href, e);
            }
        }

        if (href.startsWith("unapi:")) {
            String unapiKey = href.substring("unapi:".length());
            try {
                Element el = manager.retrievePicaXMLViaUnAPI(unapiKey);
                return new DOMSource(el);
            } catch (Exception e) {
                throw new TransformerException("Error processing UnAPI request: " + href, e);
            }
        }

        if (href.startsWith("classification:")) {
            String classid = href.substring("classification:".length());
            // if the code runs in a MyCoRe environment, 
            // use the MyCoe URIResolver to retrieve the classification
            try {
                @SuppressWarnings("rawtypes")
                Class classMCRURIResolver = Class.forName("org.mycore.common.xml.MCRURIResolver");

                try {
                    //resolving: MCRURIResolver.instance().resolve(String href, String base)
                    @SuppressWarnings("unchecked")
                    Method methodInstance = classMCRURIResolver.getMethod("instance");
                    Object o = methodInstance.invoke(null, new Object[] {});
                    @SuppressWarnings("unchecked")
                    Method methodResolve = classMCRURIResolver.getMethod("resolve", String.class, String.class);
                    String uri = "classification:metadata:-1:children:" + classid;
                    Source s = (Source) methodResolve.invoke(o, uri, "");
                    return s;

                } catch (NoSuchMethodException | SecurityException | IllegalAccessException | IllegalArgumentException
                    | InvocationTargetException e) {
                    LOGGER.error("Error with Java Reflection API", e);
                }
            } catch (ClassNotFoundException e) {
                URL url;
                try {
                    url = new URL(manager.getConfig().getMycoreUrl() + "api/v1/classifications/" + classid);
                    return new StreamSource(url.openStream());
                } catch (MalformedURLException e1) {
                    throw new TransformerException("Malformed URL", e1);
                } catch (IOException e1) {
                    throw new TransformerException("Error opening URL: " + href, e1);
                }
            }
        }

        //default:
        String path = href;
        InputStream is = getClass().getClassLoader()
            .getResourceAsStream(Pica2ModsManager.PICA2MODS_XSLT_PATH + path);
        return new StreamSource(is);
    }
}
