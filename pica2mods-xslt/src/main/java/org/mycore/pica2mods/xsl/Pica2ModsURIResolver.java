package org.mycore.pica2mods.xsl;

import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.concurrent.TimeUnit;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Element;

/**
 * This class is deprecated. Use Pica2ModsXSLTURIResolver as replacement.
 * 
 * @author Robert Stephan
 * @deprecated 2023-03-06
 */
public class Pica2ModsURIResolver implements URIResolver {
    private final Logger LOGGER = LoggerFactory.getLogger(Pica2ModsURIResolver.class);

    private Pica2ModsGenerator p2mGenerator;

    public Pica2ModsURIResolver(Pica2ModsGenerator p2mGenerator) {
        this.p2mGenerator = p2mGenerator;
    }

    @Override
    public Source resolve(String href, String base) throws TransformerException {
        //default: resolve internet sources
        if (href.startsWith("http:") || href.startsWith("https:")) {
            if (href.startsWith("https://unapi.k10plus.de?") || href.startsWith("https://sru.k10plus.de?")) {
                return gbvCatalogCall(href);
            }
            URL url;
            try {
                url = new URL(href);
                return new StreamSource(url.openStream());
            } catch (MalformedURLException e) {
                LOGGER.error("Malformed URL", e);
                throw new TransformerException(e);
            } catch (IOException e) {
                LOGGER.error("Error opening document at: " + href);
                throw new TransformerException(e);
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
                Element el = p2mGenerator.retrievePicaXMLViaSRU("gvk", query);
                return new DOMSource(el);
            } catch (Exception e) {
                LOGGER.error("Error processing SRU Query", e);
                throw new TransformerException(e);
            }
        }
        if (href.startsWith("sru-k10plus:")) {
            String query = href.substring("sru-k10plus:".length());
            try {
                Element el = p2mGenerator.retrievePicaXMLViaSRU("k10plus", query);
                return new DOMSource(el);
            } catch (Exception e) {
                LOGGER.error("Error processing SRU Query", e);
                throw new TransformerException(e);
            }
        }

        if (href.startsWith("unapi:")) {
            String id = href.substring("unapi:".length());
            try {
                Element el = p2mGenerator.retrievePicaXMLViaUnAPI(id);
                return new DOMSource(el);
            } catch (Exception e) {
                LOGGER.error("Error processing SRU Query", e);
                throw new TransformerException(e);
            }
        }

        if (href.startsWith("classification:")) {
            String classid = href.substring("classification:".length());

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
                    url = new URL(p2mGenerator.getMycoreBaseURL() + "api/v1/classifications/" + classid);
                    return new StreamSource(url.openStream());
                } catch (MalformedURLException e1) {
                    LOGGER.error("Malformed URL", e1);
                    throw new TransformerException(e1);
                } catch (IOException e1) {
                    LOGGER.error("Error opening document at: " + href);
                    throw new TransformerException(e1);
                }
            }
        }

        //default:
        String path = href;
        InputStream is = getClass().getClassLoader()
            .getResourceAsStream(Pica2ModsGenerator.PICA2MODS_XSLT_PATH + path);
        return new StreamSource(is);
    }

    private StreamSource gbvCatalogCall(String href) {
        if (!href.startsWith("http://") && !href.startsWith("https://")) {
            throw new IllegalArgumentException("The URL should start with 'http://' or 'https://'");
        }
        try {
            URL url = new URL(href);
            int loop = 0;
            do {
                loop++;
                LOGGER.debug("Getting catalogue data for: " + url.toString());
                try {
                    return new StreamSource(url.openStream());

                } catch (Exception e) {
                    if (loop <= 2) {
                        LOGGER.error("An error occurred - waiting 5 min and try again", e);
                        TimeUnit.MINUTES.sleep(5);
                    } else
                        throw e;
                }
            } while (loop <= 2);
        } catch (Exception e) {
            LOGGER.error("Error retrieving catalog data from " + href, e);
        }
        return new StreamSource(new StringReader(""));
    }
}
