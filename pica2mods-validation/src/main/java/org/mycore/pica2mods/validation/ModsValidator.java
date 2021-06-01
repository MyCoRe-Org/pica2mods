package org.mycore.pica2mods.validation;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import javax.xml.transform.stream.StreamSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import name.dmaus.schxslt.Result;
import name.dmaus.schxslt.Schematron;
import name.dmaus.schxslt.SchematronException;

public class ModsValidator {
    private static final Logger LOGGER = LoggerFactory.getLogger(ModsValidator.class);

    private static final String DEFAULT_SCHEMATRON_RESOURCE = "/validation/ubr_mods_validation.sch.xml";

    private static List<Path> SAMPLE_FILES = Arrays.<Path>asList(
        Paths.get("R:\\git\\mods_validation\\sample\\matrikel_1760.mcr.xml"),
        Paths.get("R:\\git\\mods_validation\\sample\\simoni_1567.xml"),
        Paths.get("R:\\git\\mods_validation\\sample\\gvd_marika_2009.xml"));

    private String schematronResource;

    public ModsValidator(String schematronResource) {
        this.schematronResource = schematronResource;
    }

    public static void main(String[] args) {
        ModsValidator validator = new ModsValidator(DEFAULT_SCHEMATRON_RESOURCE);
        validator.run(SAMPLE_FILES);
    }

    private void run(List<Path> paths) {
        for (Path p : paths) {
            System.out.println(p.getFileName().toString());
            run(p);
        }
    }

    private List<String> run(Path p) {
        System.out.println(p.getFileName().toString());
        StreamSource xmlSource;
        try {
            xmlSource = new StreamSource(Files.newBufferedReader(p));
            return run(xmlSource);
        } catch (IOException e) {
            LOGGER.error("Error XML file", e);
            return Arrays.asList("Error XML file: " + e.getMessage());
        }
    }

    public List<String> run(StreamSource source) {
        try {
            StreamSource streamSource = new StreamSource(getClass().getResourceAsStream(schematronResource),
                schematronResource);
            Schematron schematron = new Schematron(streamSource);
            Result result = schematron.validate(source);
            if (result.isValid()) {
                LOGGER.info("XML is valid!");
            } else {
                for (String s : result.getValidationMessages()) {
                    LOGGER.debug(s);
                }
                return result.getValidationMessages();
            }
        } catch (SchematronException e) {
            LOGGER.error("Error in Schematron processing", e);
            return Arrays.asList("Error in Schematron processing: " + e.getMessage());
        }
        return Collections.emptyList();
    }

}
