package org.mycore.pica2mods;

public class Catalog {

    private String url;

    private String unapiUrl;

    private String srudbUrl;

    private String xsl;

    public Catalog(String url, String unapiUrl, String srudbUrl, String xsl) {
        this.url = url;
        this.unapiUrl = unapiUrl;
        this.srudbUrl = srudbUrl;
        this.xsl = xsl;
    }

    public Catalog() {
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }


    public String getUnapiUrl() {
        return unapiUrl;
    }

    public void setUnapiUrl(String unapiUrl) {
        this.unapiUrl = unapiUrl;
    }

    public String getSrudbUrl() {
        return srudbUrl;
    }

    public void setSrudbUrl(String srudbUrl) {
        this.srudbUrl = srudbUrl;
    }

    public String getXsl() {
        return xsl;
    }

    public void setXsl(String xsl) {
        this.xsl = xsl;
    }

    @Override
    public String toString() {
        return url;
    }
}
