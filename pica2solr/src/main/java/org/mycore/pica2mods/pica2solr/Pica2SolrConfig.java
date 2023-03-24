package org.mycore.pica2mods.pica2solr;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "pica2solr.default-config")
public class Pica2SolrConfig implements Cloneable {

    private String solrCore;

    private String sruCatalog;

    private String sruQuery;

    private String libraryId;

    public String getSolrCore() {
        return solrCore;
    }

    public void setSolrCore(String solrCore) {
        this.solrCore = solrCore;
    }

    public String getSruCatalog() {
        return sruCatalog;
    }

    public void setSruCatalog(String sruCatalog) {
        this.sruCatalog = sruCatalog;
    }

    public String getSruQuery() {
        return sruQuery;
    }

    public void setSruQuery(String sruQuery) {
        this.sruQuery = sruQuery;
    }

    public String getLibraryId() {
        return libraryId;
    }

    public void setLibraryId(String libraryId) {
        this.libraryId = libraryId;
    }
    
    public Pica2SolrConfig clone(){
        try {
            return (Pica2SolrConfig)super.clone();
        } catch (CloneNotSupportedException e) {
            return null; //should not happen
        }
    }

}
