/*
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * MyCoRe is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyCoRe is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.mycore.pica2mods.xsl.model;

public class Catalog {

    private String opacUrl;

    private String unapiKey;

    private String sruKey;

    private String xsl;

    public Catalog(String opacUrl, String unapiKey, String sruKey, String xsl) {
        this.opacUrl = opacUrl;
        this.unapiKey = unapiKey;
        this.sruKey = sruKey;
        this.xsl = xsl;
    }

    public Catalog() {
    }

    public String getOpacUrl() {
        return opacUrl;
    }

    public void setOpacUrl(String url) {
        this.opacUrl = url;
    }

    public String getUnapiKey() {
        return unapiKey;
    }

    public void setUnapiKey(String unapiKey) {
        this.unapiKey= unapiKey;
    }

    public String getSruKey() {
        return sruKey;
    }

    public void setSruKey(String sruKey) {
        this.sruKey = sruKey;
    }

    public String getXsl() {
        return xsl;
    }

    public void setXsl(String xsl) {
        this.xsl = xsl;
    }

    @Override
    public String toString() {
        return opacUrl;
    }
}
