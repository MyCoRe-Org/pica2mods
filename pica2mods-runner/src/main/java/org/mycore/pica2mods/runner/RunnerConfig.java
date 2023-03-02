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

package org.mycore.pica2mods.runner;

import java.util.HashMap;
import java.util.Map;

import org.mycore.pica2mods.runner.model.Catalog;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableConfigurationProperties
@ConfigurationProperties(prefix = "pica2mods")
public class RunnerConfig {

    private String defaultCatalogName;

    private Map<String, Catalog> catalogs;

    private String sruUrl;

    private String unapiUrl;

    public String getDefaultCatalogName() {
        return defaultCatalogName;
    }

    public void setDefaultCatalogName(String defaultCatalogName) {
        this.defaultCatalogName = defaultCatalogName;
    }

    public Map<String, Catalog> getCatalogs() {
        return catalogs;
    }

    public void setCatalogs(Map<String, Catalog> catalogs) {
        this.catalogs = catalogs;
    }

    public String getSruUrl() {
        return sruUrl;
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
}
