package org.mycore.pica2mods;

import java.util.Iterator;

import javax.xml.XMLConstants;
import javax.xml.namespace.NamespaceContext;

public class Pica2ModsNamespaceContext implements NamespaceContext {

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

    @SuppressWarnings({ "rawtypes" })
    public Iterator getPrefixes(String namespace) {
        return null;
    }
}
