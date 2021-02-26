package org.mycore.pica2mods.web.model;

public class PPNLink {

    public PPNLink(String type, String ppn) {
        super();
        this.type = type;
        this.ppn = ppn;
    }

    private String type;

    private String ppn;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getPpn() {
        return ppn;
    }

    public void setPpn(String ppn) {
        this.ppn = ppn;
    }
}
