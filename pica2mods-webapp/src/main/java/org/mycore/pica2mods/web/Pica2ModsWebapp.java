package org.mycore.pica2mods.web;

import org.mycore.pica2mods.xsl.Pica2ModsGenerator;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Pica2ModsWebapp {
    public static final String PICA2MODS_VERSION = Pica2ModsGenerator.retrieveBuildInfosFromManifest(true);

    public static final String DEFAULT_CATALOG_KEY_K10PLUS = "k10plus";
    
    public static void main(String[] args) throws Exception {
        SpringApplication.run(Pica2ModsWebapp.class, args);
    }
}
