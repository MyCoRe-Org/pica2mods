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

import java.io.StringWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.xml.transform.Result;
import javax.xml.transform.stream.StreamResult;

import org.mycore.pica2mods.xsl.Pica2ModsManager;
import org.mycore.pica2mods.xsl.model.Catalog;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Runner implements ApplicationRunner {

    private final static Logger LOGGER = LoggerFactory.getLogger(Runner.class);

    private static final String PICA2MODS_VERSION = Pica2ModsManager.retrieveBuildInfosFromManifest(true);

    private final static String CATALOG_OPTION = "catalog";

    private final static String OUTPUT_OPTION = "output";

    private final static Set<String> VALID_OPTION_NAMES = new HashSet<>(Arrays.asList(CATALOG_OPTION, OUTPUT_OPTION));

    @Autowired
    private RunnerConfig config;

    public static void main(String[] args) {
        SpringApplication.run(Runner.class, args);
    }

    @Override
    public void run(ApplicationArguments args) {
        final List<String> nonOptionArgs = args.getNonOptionArgs();
        if (nonOptionArgs.size() != 2) {
            System.out.println("A MyCoRe base url and ppn must be specified at least.");
            System.exit(1);
        }
        final Set<String> unknownOptionNames = new HashSet<>(args.getOptionNames());
        unknownOptionNames.removeAll(VALID_OPTION_NAMES);
        if (!unknownOptionNames.isEmpty()) {
            System.out.println("Found unknown options:");
            System.out.println(unknownOptionNames);
            System.exit(1);
        }

        final String baseUrl = nonOptionArgs.get(0);
        final String ppn = nonOptionArgs.get(1);
        final String catalogName = getOptionValue(args, CATALOG_OPTION);
        Catalog catalog = null;
        if (catalogName == null) {
            catalog = config.getCatalogs().get(config.getDefaultCatalogName());
            LOGGER.info("No catalog specified, using default catalog: {}.", config.getDefaultCatalogName());
        } else {
            catalog = config.getCatalogs().get(catalogName);
            if (catalog == null) {
                System.out.println("Unknown catalog: " + catalogName);
                System.exit(1);
            }
        }
        final String output = getOptionValue(args, OUTPUT_OPTION);
        try {
            final String result = transform(baseUrl, catalog, ppn);
            if (output != null) {
                Files.writeString(Path.of(output), result);
            } else {
                System.out.println(result);
            }
        } catch (Exception e) {
            System.out.println("Error while transforming/outputing: " + e);
            System.exit(1);
        }
    }

    // TODO exceptions are crappy
    private String transform(String baseUrl, Catalog catalog, String ppn) throws Exception {
        final StringWriter sw = new StringWriter();
        final Result result = new StreamResult(sw);
        final Pica2ModsManager pica2modsManager = new Pica2ModsManager(config);
        final Map<String, String> xslParams = new HashMap<>();
        xslParams.put("MCR.PICA2MODS.CONVERTER_VERSION", PICA2MODS_VERSION);
        xslParams.put("MCR.PICA2MODS.DATABASE", catalog.getUnapiKey());
        pica2modsManager.createMODSDocumentViaSRU(catalog.getSruKey(), "pica.ppn=" + ppn, result, xslParams);
        return sw.toString();
    }

    private static String getOptionValue(ApplicationArguments args, String optionName) {
        return args.containsOption(optionName) ? args.getOptionValues(optionName).get(0) : null;
    }
}
