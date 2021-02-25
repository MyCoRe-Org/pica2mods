package org.mycore.pica2mods.controller;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.apache.tomcat.util.http.fileupload.IOUtils;
import org.mycore.pica2mods.Pica2ModsMetadataService;
import org.mycore.pica2mods.util.XMLSchemaValidator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

@Controller
public class Pica2ModsController {

    @Autowired
    private Pica2ModsXSLTransformerService transformer;

    @Autowired
    private Pica2ModsMetadataService metadataService;

    @Value("#{'${pica2mods.catalogs}'.split(',')}")
    private List<String> catalogs;

    @Value("#{${pica2mods.catalogs.names}}")
    private Map<String, String> catalogNames;

    @Value("#{${pica2mods.catalogs.urls}}")
    private Map<String, String> catalogUrls;

    @Value("#{${pica2mods.catalogs.unapikeys}}")
    private Map<String, String> catalogUnapiKeys;

    @GetMapping("/")
    String index(@RequestParam(name = "ppn", required = false) String ppn,
        @RequestParam(name = "catalog", defaultValue = "ubr") String catalog,
        Model model) {

        model.addAttribute("catalog", catalog);
        model.addAttribute("catalogs", catalogs);
        model.addAttribute("catalogNames", catalogNames);
        model.addAttribute("catalogUrls", catalogUrls);
        model.addAttribute("catalogUnapiKeys", catalogUnapiKeys);
        model.addAttribute("related", metadataService.resolveOtherIssues(catalog, ppn));

        if (ppn != null) {
            ppn = ppn.trim();
            model.addAttribute("ppn", ppn);

            String modsXML = transformer.transform(ppn);
            model.addAttribute("modsxml", modsXML);

            model.addAttribute("ppnA", transformer.retrieveAPPN(modsXML));
            String ppnHost = transformer.retrieveHostPPN(modsXML);
            if (ppnHost != null && !ppnHost.isEmpty()) {
                model.addAttribute("ppnHost", ppnHost);
            }

            XMLSchemaValidator xsv = new XMLSchemaValidator();
            boolean isValid = xsv.validate(modsXML);
            if (!isValid) {
                model.addAttribute("xmlSchemaError", xsv.getErrorMsg());
            }

        } else {
            model.addAttribute("ppn", "");
            model.addAttribute("modsxml", "");
        }

        //add XSL-Files to model
        List<String> xslFiles = new ArrayList<String>();
        try {
            PathMatchingResourcePatternResolver xslFileResolver = new PathMatchingResourcePatternResolver();
            Resource[] resources = xslFileResolver.getResources("classpath*:xsl/**/*.xsl");
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
                String x = "xsl/" + request.getServletPath().replace("/files/xsl", "").replaceAll("\\.+", ".");
                try (InputStream is = getClass().getClassLoader().getResourceAsStream(x)) {
                    //Java9: //inputStream.transferTo(targetStream);
                    IOUtils.copy(is, outputStream);
                }
            }
        };
    }

    @RequestMapping(value = "/ppn{ppn}.mods.xml",
        method = RequestMethod.GET,
        produces = {
            MediaType.APPLICATION_XML_VALUE })
    @ResponseBody
    String getXML(@PathVariable(name = "ppn", required = false) String ppn, Model model) {
        return transformer.transform(ppn);
    }

}
