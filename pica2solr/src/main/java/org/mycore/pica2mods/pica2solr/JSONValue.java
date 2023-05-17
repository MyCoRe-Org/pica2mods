package org.mycore.pica2mods.pica2solr;

import java.util.Locale;

//"borrowed" Escape-functions from org.json.simple.JSONValue
//https://github.com/fangyidong/json-simple/blob/2f4b7b5bed38d7518bf9c6a902ea909226910ae3/src/main/java/org/json/simple/JSONValue.java#L258

public class JSONValue {
    /**
     * Escape quotes, \, /, \r, \n, \b, \f, \t and other control characters (U+0000
     * through U+001F).
     * 
     * @param s
     * @return the escaped string
     */
    public static String escape(String s) {
        if (s == null)
            return null;
        StringBuffer sb = new StringBuffer();
        escape(s, sb);
        return sb.toString();
    }

    /**
     * @param s  - Must not be null.
     * @param sb
     */
    static void escape(String s, StringBuffer sb) {
        final int len = s.length();
        for (int i = 0; i < len; i++) {
            char ch = s.charAt(i);
            switch (ch) {
            case '"':
                sb.append("\\\"");
                break;
            case '\\':
                sb.append("\\\\");
                break;
            case '\b':
                sb.append("\\b");
                break;
            case '\f':
                sb.append("\\f");
                break;
            case '\n':
                sb.append("\\n");
                break;
            case '\r':
                sb.append("\\r");
                break;
            case '\t':
                sb.append("\\t");
                break;
            case '/':
                sb.append("\\/");
                break;
            default:
                // Reference: http://www.unicode.org/versions/Unicode5.1.0/
                if ((ch >= '\u0000' && ch <= '\u001F') || (ch >= '\u007F' && ch <= '\u009F') || (ch >= '\u2000' && ch <= '\u20FF')) {
                    String ss = Integer.toHexString(ch);
                    sb.append("\\u");
                    for (int k = 0; k < 4 - ss.length(); k++) {
                        sb.append('0');
                    }
                    sb.append(ss.toUpperCase(Locale.getDefault()));
                } else {
                    sb.append(ch);
                }
            }
        } // for
    }

    public static String escapeXML(String s) {
        if (s == null)
            return null;
        StringBuffer sb = new StringBuffer();
        final int len = s.length();
        for (int i = 0; i < len; i++) {
            char ch = s.charAt(i);
            switch (ch) {
            case '"':
                sb.append("&quot;");
                break;
            case '<':
                sb.append("&lt;");
                break;
            case '>':
                sb.append("&gt;");
                break;
            case '&':
                sb.append("&amp;");
                break;
            default:
                sb.append(ch);
            }
        }
        return sb.toString();
    }
}
