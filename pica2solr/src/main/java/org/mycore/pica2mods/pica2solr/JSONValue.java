package org.mycore.pica2mods.pica2solr;

import java.util.Locale;

/**
 * Utility functions to escape control characters for JSON output
 * 
 * They are based on org.json.simple.JSONValue:
 * https://github.com/fangyidong/json-simple/blob/2f4b7b5bed38d7518bf9c6a902ea909226910ae3/src/main/java/org/json/simple/JSONValue.java#L258
 */
public class JSONValue {
    /**
     * Escape quotes, \, /, \r, \n, \b, \f, \t and other control characters (U+0000  through U+001F)
     * for JSON output.
     * 
     * @param s the string to escape
     * @return the escaped string
     */
    public static String escape(String s) {
        if (s == null) {
            return null;
        }
        StringBuilder sb = new StringBuilder();
        escape(s, sb);
        return sb.toString();
    }

    /**
     * Escape quotes, \, /, \r, \n, \b, \f, \t and other control characters (U+0000  through U+001F)
     * for JSON output.
     * The escape function
     * @param s  -the string to escape
     * @param sb - the string buffer that should hold the result
     */
    public static void escape(String s, StringBuilder sb) {
        if (s == null) {
            return;
        }
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
                    if ((ch >= '\u0000' && ch <= '\u001F') || (ch >= '\u007F' && ch <= '\u009F')
                        || (ch >= '\u2000' && ch <= '\u20FF')) {
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
        }
    }

    /**
     * Escape XML entities for JSON output.
     * 
     * @param s the string to escape
     * @return the escaped string
     */
    public static String escapeXML(String s) {
        if (s == null)
            return null;
        StringBuilder sb = new StringBuilder();
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
