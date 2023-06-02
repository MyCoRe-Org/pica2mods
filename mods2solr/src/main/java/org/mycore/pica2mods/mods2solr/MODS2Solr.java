package org.mycore.pica2mods.mods2solr;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.List;
import java.util.Locale;

import javax.xml.namespace.QName;
import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.events.XMLEvent;

import org.mycore.pica2mods.mods2solr.service.SolrService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.util.StringUtils;

@SpringBootApplication
public class MODS2Solr implements ApplicationRunner {

    @Autowired
    SolrService solrService;

    @Autowired
    MODS2SolrConfig defaultConfig;

    public static final String MODS2SOLR_CMD_LIST_CORES = "list-cores";

    public static final String MODS2SOLR_CMD_INIT_CORE = "init-core";

    public static final String MODS2SOLR_CMD_CLEAR_CORE = "clear-core";

    public static final String MODS2SOLR_CMD_RUN = "run";

    private static XMLInputFactory XML_INPUT_FACTORY = XMLInputFactory.newInstance();

    static {
        XML_INPUT_FACTORY.setProperty(XMLInputFactory.IS_SUPPORTING_EXTERNAL_ENTITIES, false);
    }

    private static QName QN_ATTR_ID = new QName("ID");

    private static QName QN_ATTR_HREF = new QName("href");

    private static QName QN_MYCOREOBJECT = new QName("mycoreobject");

    public static int OFFSET = 250;

    //private static  HttpClient HTTP_CLIENT() {return HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).connectTimeout(Duration.ofSeconds(30)).build();}
    private static HttpClient HTTP_CLIENT() {
        return HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).connectTimeout(Duration.ofSeconds(30))
            .build();
    }

    public static void main(String[] args) {
        //SpringApplication.run(MODS2Solr.class, new String[] { MODS2SOLR_CMD_INIT_CORE, "--solr_core=mods_rosdok" }); 
        SpringApplication.run(MODS2Solr.class,
            new String[] { MODS2SOLR_CMD_RUN, "--solr_core=mods_rosdok",
                "--mycore_rest_objects=https://rosdok.uni-rostock.de/api/v1/objects/",
                "--resume_id=rosdok_document_0000005000" });
        //SpringApplication.run(MODS2Solr.class, args);
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        MODS2SolrConfig config = createConfigFromArgs(args);
        if (args.getNonOptionArgs().size() == 0) {
            System.out.println("MODS2Solr");
            System.out.println("-----------------------------");
            System.out
                .println("for help and commandline arguments see https://github.com/MyCoRe-Org/mods2solr");
            return;
        }

        if (args.getNonOptionArgs().size() > 0) {
            String command = args.getNonOptionArgs().get(0);
            switch (command) {
                case MODS2SOLR_CMD_LIST_CORES:
                    List<String> cores = solrService.listCores();
                    System.out.println("Cores in Solr:");
                    for (String c : cores) {
                        System.out.println(" - " + c);
                    }
                    break;
                case MODS2SOLR_CMD_INIT_CORE:
                    if (args.getNonOptionArgs().size() > 1) {
                        String name = args.getNonOptionArgs().get(1);
                        if (solrService.initCore(name)) {
                            System.out.println("The Solr core '" + name + "' was initialized successfully.");
                        }
                    } else {
                        System.err.println("Please specify the name of the core");
                    }
                    break;
                case MODS2SOLR_CMD_CLEAR_CORE:
                    if (args.getNonOptionArgs().size() > 1) {
                        String name = args.getNonOptionArgs().get(1);
                        if (solrService.clearCore(name)) {
                            System.out.println("The Solr core '" + name + "' was cleared successfully.");
                        }
                    } else {
                        System.err.println("Please specify the name of the core");
                    }
                    break;
                case MODS2SOLR_CMD_RUN:
                    System.out.println("\n>>>> Pica2Solr starts with the following parameter:");
                    System.out.println("      - Solr core   : " + config.getSolrCore());
                    System.out.println(">>>> Start");

                    if (processMyCoReObjects(config)) {
                        System.out.println(">>>> The operation completed successfully,");
                    } else {
                        System.err.println(">>>> The operation finished with an error!");
                    }
                    break;
            }
        }
    }

    private MODS2SolrConfig createConfigFromArgs(ApplicationArguments args) {
        MODS2SolrConfig config = defaultConfig.clone();
        List<String> solrCore = args.getOptionValues("solr_core");
        if (solrCore != null && solrCore.size() == 1) {
            config.setSolrCore(solrCore.get(0));
        }
        List<String> mycoreRestObjects = args.getOptionValues("mycore_rest_objects");
        if (mycoreRestObjects != null && mycoreRestObjects.size() == 1) {
            config.setMycoreRestObjects(mycoreRestObjects.get(0));
        }
        List<String> resumeIds = args.getOptionValues("resume_id");
        if (resumeIds != null && resumeIds.size() == 1) {
            config.setResumeId(resumeIds.get(0));
        }
        return config;
    }

    private boolean processMyCoReObjects(MODS2SolrConfig config) {
        MODSProcessor modsProc = new MODSProcessor();
        try {
            List<String> cores = solrService.listCores();
            if (!cores.contains(config.getSolrCore())) {
                solrService.initCore(config.getSolrCore());
            }

            int start = 0001;
            String ingest = null;
            HttpRequest requestListObjects = HttpRequest.newBuilder().uri(URI.create(config.getMycoreRestObjects()))
                .GET()//.setHeader("User-Agent", "Pica2Solr") // add request header
                .setHeader("Content-Type", "text/xml").build();

            HttpResponse<InputStream> responseListObjects = HTTP_CLIENT().send(requestListObjects,
                HttpResponse.BodyHandlers.ofInputStream());

            try (InputStream isList = responseListObjects.body()) {
                Reader fileReader = new BufferedReader(new InputStreamReader(isList, StandardCharsets.UTF_8));
                XMLEventReader xmlEventReader = XML_INPUT_FACTORY.createXMLEventReader(fileReader);
                while (xmlEventReader.hasNext()) {
                    XMLEvent xmlEvent = xmlEventReader.nextEvent();
                    if (xmlEvent.isStartElement()) {
                        if (xmlEvent.asStartElement().getName().equals(QN_MYCOREOBJECT)) {
                            ++start;
                            String id = xmlEvent.asStartElement().getAttributeByName(QN_ATTR_ID).getValue();
                            if (StringUtils.hasText(config.getResumeId()) && id.compareTo(config.getResumeId()) < 0) {
                                continue;
                            }
                            String uri = xmlEvent.asStartElement().getAttributeByName(QN_ATTR_HREF).getValue();
                            System.out.println("  >>" + String.format(Locale.getDefault(), "%6d", start) + " : " + uri);
                            HttpRequest requestSRU = HttpRequest.newBuilder().uri(URI.create(uri)).GET()//.setHeader("User-Agent", "Pica2Solr") // add request header
                                .setHeader("Content-Type", "text/xml").build();

                            HttpResponse<InputStream> responseSRU = HTTP_CLIENT().send(requestSRU,
                                HttpResponse.BodyHandlers.ofInputStream());

                            try (InputStream is = responseSRU.body()) {
                                ingest = modsProc.process(id, is);
                                if (ingest.length() > 10) {
                                    solrService.updateSolrDocuments(config.getSolrCore(), ingest);
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            //LoggerFactory.getLogger(MODSProcessor.class).error("MODS processing failed.", e);
            e.printStackTrace();
            return false;
        }

        return true;
    }

    // use default solrconfig.xml and add at the bottom:   <schemaFactory class="ClassicIndexSchemaFactory"/>

}
