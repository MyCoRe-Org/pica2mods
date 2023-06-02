package org.mycore.pica2mods.mods2solr;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "mods2solr.default-config")
public class MODS2SolrConfig implements Cloneable {

    private String solrCore;

    private String mycoreRestObjects;

    private String resumeId;

    public String getSolrCore() {
        return solrCore;
    }

    public void setSolrCore(String solrCore) {
        this.solrCore = solrCore;
    }

    public MODS2SolrConfig clone() {
        try {
            return (MODS2SolrConfig) super.clone();
        } catch (CloneNotSupportedException e) {
            return null; //should not happen
        }
    }

    public String getMycoreRestObjects() {
        return mycoreRestObjects;
    }

    public void setMycoreRestObjects(String mycoreRestObjects) {
        this.mycoreRestObjects = mycoreRestObjects;
    }

    public String getResumeId() {
        return resumeId;
    }

    public void setResumeId(String resumeId) {
        this.resumeId = resumeId;
    }

}
