package org.mycore.pica2mods.pica2solr;

import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;

import org.mycore.pica2mods.pica2solr.service.SolrService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.util.StringUtils;

@SpringBootApplication
public class Pica2Solr implements ApplicationRunner {

    @Autowired
    SolrService solrService;

    @Autowired
    Pica2SolrConfig defaultConfig;

    @Value("${pica2solr.sru_base_url}")
    private String sruBaseURL;

    public static final String PICA2SOLR_CMD_LIST_CORES = "list-cores";

    public static final String PICA2SOLR_CMD_INIT_CORE = "init-core";

    public static final String PICA2SOLR_CMD_CLEAR_CORE = "clear-core";

    public static final String PICA2SOLR_CMD_RUN = "run";

    public static int OFFSET = 250;

    //private static  HttpClient HTTP_CLIENT() {return HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).connectTimeout(Duration.ofSeconds(30)).build();}
    private static HttpClient HTTP_CLIENT() {
        return HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).connectTimeout(Duration.ofSeconds(30))
            .build();
    }

    public static void main(String[] args) {
        SpringApplication.run(Pica2Solr.class, new String[] { PICA2SOLR_CMD_RUN, "--solr-core=pica_04" });
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        Pica2SolrConfig config = createConfigFromArgs(args);
        if (args.getNonOptionArgs().size() > 0) {
            String command = args.getNonOptionArgs().get(0);
            switch (command) {
                case PICA2SOLR_CMD_LIST_CORES:
                    List<String> cores = solrService.listCores();
                    System.out.println("Cores in Solr:");
                    for (String c : cores) {
                        System.out.println(" - " + c);
                    }
                    break;
                case PICA2SOLR_CMD_INIT_CORE:
                    if (args.getNonOptionArgs().size() > 1) {
                        String name = args.getNonOptionArgs().get(1);
                        if (solrService.initCore(name)) {
                            System.out.println("The Solr core '" + name + "' was initialized successfully.");
                        }
                    } else {
                        System.err.println("Please specify the name of the core");
                    }
                    break;
                case PICA2SOLR_CMD_CLEAR_CORE:
                    if (args.getNonOptionArgs().size() > 1) {
                        String name = args.getNonOptionArgs().get(1);
                        if (solrService.clearCore(name)) {
                            System.out.println("The Solr core '" + name + "' was cleared successfully.");
                        }
                    } else {
                        System.err.println("Please specify the name of the core");
                    }
                    break;
                case PICA2SOLR_CMD_RUN:
                    System.out.println("\n>>>> Pica2Solr starts with the following parameter:");
                    System.out.println("      - Solr core   : " + config.getSolrCore());
                    System.out.println("      - SRU catalog : " + config.getSruCatalog());
                    System.out.println("      - SRU query   : " + config.getSruQuery());
                    System.out.println(">>>> Start");
                    
                    if (StringUtils.hasText(config.getLibraryId())) {
                        System.out.println("      - Library Id  : " + config.getLibraryId());
                    }
                    if (processQuery(config)) {
                        System.out.println(">>>> The operation completed successfully,");
                    }
                    else {
                        System.err.println(">>>> The operation finished with an error!");
                    }
                    break;
            }
        }
    }

    private Pica2SolrConfig createConfigFromArgs(ApplicationArguments args) {
        Pica2SolrConfig config = defaultConfig.clone();
        List<String> solrCore = args.getOptionValues("solr-core");
        if (solrCore != null && solrCore.size() == 1) {
            config.setSolrCore(solrCore.get(0));
        }
        List<String> sruCatalog = args.getOptionValues("sru-catalog");
        if (sruCatalog != null && sruCatalog.size() == 1) {
            config.setSruCatalog(sruCatalog.get(0));
        }
        List<String> sruQuery = args.getOptionValues("sru-query");
        if (sruQuery != null && sruQuery.size() == 1) {
            config.setSruQuery(sruQuery.get(0));
        }
        List<String> libraryId = args.getOptionValues("library-id");
        if (libraryId != null && libraryId.size() == 1) {
            config.setLibraryId(libraryId.get(0));
        }
        return config;
    }

    private boolean processQuery(Pica2SolrConfig config) {
        SRUProcessor sruProc = new SRUProcessor();
        try {
            List<String> cores = solrService.listCores();
            if (!cores.contains(config.getSolrCore())) {
                solrService.initCore(config.getSolrCore());
            }

            int start = 0001;
            String ingest = null;

            do {
                System.out.print("  >>" + String.format("%6d", start) + " :");
                String uri = sruBaseURL + config.getSruCatalog() + "?operation=searchRetrieve&maximumRecords=" + OFFSET
                    + "&recordSchema=picaxml"
                    + "&startRecord=" + start
                    + "&query=" + config.getSruQuery();
                HttpRequest requestSRU = HttpRequest.newBuilder().uri(URI.create(uri)).GET()//.setHeader("User-Agent", "Pica2Solr") // add request header
                    .setHeader("Content-Type", "text/xml").build();

                HttpResponse<InputStream> responseSRU = HTTP_CLIENT().send(requestSRU,
                    HttpResponse.BodyHandlers.ofInputStream());

                try (InputStream is = responseSRU.body()) {
                    ingest = sruProc.process(is, config.getLibraryId());
                }

                long count = ingest.chars().filter(ch -> ch == '{').count();
                System.out.println(" ( anz=" + count + " )");

                if (ingest.length() > 10) {
                    solrService.updateSolrDocuments(config.getSolrCore(), ingest);
                }
                start = start + OFFSET;
            } while (ingest.length() > 10);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
        return true;
    }

    // use default solrconfig.xml and add at the bottom:   <schemaFactory class="ClassicIndexSchemaFactory"/>

}
