package org.mycore.pica2mods.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.mycore.pica2mods.util.XMLSchemaValidator;
import org.springframework.beans.factory.annotation.Autowired;
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

@Controller
public class Pica2ModsController {

    @Autowired
    private Pica2ModsXSLTransformerService transformer;

    @GetMapping("/")
    String index(@RequestParam(name = "ppn", required = false) String ppn, Model model) {
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
            Resource[] resources = xslFileResolver.getResources("classpath*:META-INF/resources/xsl/**/*.xsl");
            for (Resource r : resources) {
                String s = r.getURL().toString();
                xslFiles.add(s.substring(s.lastIndexOf("/META-INF/resources/xsl/") + 24));
            }
        } catch (IOException e) {
            LogManager.getLogger(Pica2ModsController.class).error(e);
        }

        model.addAttribute("xslFiles", xslFiles);

        return "index";
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
