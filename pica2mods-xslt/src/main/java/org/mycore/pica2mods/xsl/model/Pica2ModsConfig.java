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

import java.util.Collections;
import java.util.Map;

public class Pica2ModsConfig {
    
    private String defaultCatalogKey;

    private String sruUrl;

    private String unapiUrl;

    private String mycoreUrl;

    private Map<String, Catalog> catalogs = Collections.emptyMap();

    public String getDefaultCatalogKey() {
        return defaultCatalogKey;
    }

    public void setDefaultCatalogKey(String defaultCatalogKey) {
        this.defaultCatalogKey = defaultCatalogKey;
    }

    public Map<String, Catalog> getCatalogs() {
        return catalogs;
    }

    public Catalog getCatalog(String name) {
        return catalogs.get(name);
    }

    public void setCatalogs(Map<String, Catalog> catalogs) {
        this.catalogs = catalogs;
    }

    public String getSruUrl() {
        if (sruUrl.endsWith("/")) {
            return sruUrl;
        } else {
            return sruUrl + "/";
        }
    }

    public void setSruUrl(String sruUrl) {
        this.sruUrl = sruUrl;
    }

    public String getUnapiUrl() {
        return unapiUrl;
    }

    public void setUnapiUrl(String unapiUrl) {
        this.unapiUrl = unapiUrl;
    }

    public String getMycoreUrl() {
        if (mycoreUrl.endsWith("/")) {
            return mycoreUrl;
        } else {
            return mycoreUrl + "/";
        }
    }

    public void setMycoreUrl(String mycoreUrl) {
        this.mycoreUrl = mycoreUrl;
    }
}
