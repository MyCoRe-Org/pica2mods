package org.mycore.pica2mods;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Pica2ModsWebapp {
    public static final String PICA2MODS_VERSION = Pica2ModsGenerator.retrieveBuildInfosFromManifest(true);

    public static void main(String[] args) throws Exception {
        SpringApplication.run(Pica2ModsWebapp.class, args);
    }
}
