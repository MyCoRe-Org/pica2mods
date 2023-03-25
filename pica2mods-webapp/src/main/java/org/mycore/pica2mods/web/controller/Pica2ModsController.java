package org.mycore.pica2mods.web.controller;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletRequest;
import javax.xml.transform.stream.StreamSource;

import org.apache.logging.log4j.LogManager;
import org.apache.tomcat.util.http.fileupload.IOUtils;
import org.mycore.pica2mods.validation.ModsValidator;
import org.mycore.pica2mods.web.Pica2ModsWebapp;
import org.mycore.pica2mods.web.Pica2ModsWebappConfig;
import org.mycore.pica2mods.web.util.XMLSchemaValidator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

@Controller
public class Pica2ModsController {

    @Autowired
    private Pica2ModsXSLTransformerService transformerService;
    
    @Autowired
    Pica2ModsWebappConfig config;

    @Value("${pica2mods.validation.schematron_resource}")
    private String schematronResource;
    
    private ModsValidator modsValidator;
    
    @PostConstruct
    private void init() {
        modsValidator = new ModsValidator(schematronResource);
    }

    @GetMapping("/")
    String index(@RequestParam(name = "ppn", required = false) String ppn,
        @RequestParam(name = "catalog", defaultValue = "ubr") String catalog,
        Model model) {

        model.addAttribute("catalogId", catalog==null ? config.getDefaultCatalogKey() : catalog);
        model.addAttribute("catalogs", config.getCatalogs());
        model.addAttribute("related", transformerService.resolveOtherIssues(catalog, ppn));
        model.addAttribute("pica2modsVersion", Pica2ModsWebapp.PICA2MODS_VERSION);

        if (ppn != null) {
            ppn = ppn.trim();
            model.addAttribute("ppn", ppn);

            String modsXML = transformerService.transform(catalog, ppn);
            model.addAttribute("modsxml", modsXML);

            XMLSchemaValidator xsv = new XMLSchemaValidator();
            boolean isValid = xsv.validate(modsXML);
            model.addAttribute("isValid", isValid);
            if (!isValid) {
                model.addAttribute("xmlSchemaError", xsv.getErrorMsg());
            }
            if ("ubr".equals(catalog)) {
                List<String> result = modsValidator.run(new StreamSource(new StringReader(modsXML)));
                if (!result.isEmpty()) {
                    model.addAttribute("schematronError", result);
                    model.addAttribute("isValid", false);
                }
            }
        } else {
            model.addAttribute("ppn", "");
            model.addAttribute("modsxml", "");
        }

        //add XSL-Files to model
        List<String> xslFiles = new ArrayList<String>();
        try {
            PathMatchingResourcePatternResolver xslFileResolver = new PathMatchingResourcePatternResolver();
            Resource[] resources = xslFileResolver.getResources("classpath*:xsl/**/*.x?l");
            for (Resource r : resources) {
                String s = r.getURL().toString();
                xslFiles.add(s.substring(s.lastIndexOf("xsl/") + 4));
            }
        } catch (IOException e) {
            LogManager.getLogger(Pica2ModsController.class).error(e);
        }

        model.addAttribute("xslFiles", xslFiles);

        return "index";
    }

    @GetMapping(value = "/files/xsl/**", produces = MediaType.APPLICATION_XML_VALUE)
    @ResponseBody
    StreamingResponseBody returnXSLFile(HttpServletRequest request) {
        return new StreamingResponseBody() {

            @Override
            public void writeTo(OutputStream outputStream) throws IOException {
                //String x = "xsl/"+filepath;
                String x = "xsl" + request.getServletPath()
                    .substring(request.getServletPath().indexOf("/files/xsl") + "/files/xsl".length())
                    .replaceAll("\\.+", ".");
                try (InputStream is = getClass().getClassLoader().getResourceAsStream(x)) {
                    //Java9: //inputStream.transferTo(targetStream);
                    IOUtils.copy(is, outputStream);
                }
            }
        };
    }

    @GetMapping(value = "/ppn{ppn}.mods.xml", produces = { MediaType.APPLICATION_XML_VALUE })
    @ResponseBody
    String getXML(@PathVariable(name = "ppn", required = false) String ppn,
        @RequestParam(name = "catalog", required = false, defaultValue = "ubr") String catalog,
        Model model) {
        return transformerService.transform(catalog, ppn);
    }

}
