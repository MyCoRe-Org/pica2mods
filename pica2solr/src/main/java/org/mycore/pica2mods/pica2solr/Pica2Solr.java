package org.mycore.pica2mods.pica2solr;

import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpRequest.BodyPublishers;
import java.net.http.HttpResponse;
import java.time.Duration;

public class Pica2Solr {

    public static String SOLR_BASEURL = "http://localhost:8983/solr/";
    public static String SRU_BASEURL = "https://sru.k10plus.de/";

    public static String SOLR_CORE = "pica_rosdok";
    public static String SRU_CATALOG = "gvk";

    //public static String SRU_QUERY = "query=pica.url%3Dpurl*rosdokid*";
    public static String SRU_QUERY = "query=pica.url%3Dpurl*rosdok*";
    
    //ID der Besitzenden Bibliothek für Filterung nach Exemplaren (Pica 101@/a)
    //public static String LIB_OWNER_ID="62";
    public static String LIB_OWNER_ID=null;

    public static int OFFSET=250;
    
    //private static  HttpClient HTTP_CLIENT() {return HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).connectTimeout(Duration.ofSeconds(30)).build();}
    private static  HttpClient HTTP_CLIENT() {return HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).connectTimeout(Duration.ofSeconds(30)).build();}

    public static void main(String[] args) {
        Pica2Solr app = new Pica2Solr();
        app.run(SOLR_CORE, SRU_CATALOG, SRU_QUERY);
    }

    private void run(String solrCore, String sruCatalog, String sruQuery) {
        SRUProcessor sruProc = new SRUProcessor();
        try {
            //clearSolrCollection();
            initCore(solrCore);
            int start = 0001;
            String ingest = null;

            do {
                System.out.print(">> " + start + " :");
                String uri = SRU_BASEURL + sruCatalog + "?operation=searchRetrieve&maximumRecords="+OFFSET+"&recordSchema=picaxml&startRecord=" + start + "&query="
                        + sruQuery;
                HttpRequest requestSRU = HttpRequest.newBuilder().uri(URI.create(uri)).GET()//.setHeader("User-Agent", "Pica2Solr") // add request header
                        .setHeader("Content-Type", "text/xml").build();

                HttpResponse<InputStream> responseSRU = HTTP_CLIENT().send(requestSRU, HttpResponse.BodyHandlers.ofInputStream());

                try(InputStream is = responseSRU.body()){
                    ingest = sruProc.process(is, LIB_OWNER_ID);
                }
                
                long count = ingest.chars().filter(ch -> ch == '{').count();
                System.out.println(" ( anz="+count+" )");
                
                if (ingest.length() > 10) {
                    updateSolrDocuments(ingest);
                }
                start = start + OFFSET;
            } while (ingest.length() > 10);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // http://host:port/solr/core_name/update?commit=true&stream.body=<delete><query>*:*</query></delete>"
    public void clearSolrCollection(String core) throws IOException, InterruptedException {
        String uri = SOLR_BASEURL + core + "/update?commit=true";

        HttpRequest request = HttpRequest.newBuilder().uri(URI.create(uri)).POST(BodyPublishers.ofString("<delete><query>*:*</query></delete>"))
                .setHeader("User-Agent", "Pica2Solr") // add request header
                .setHeader("Content-Type", "text/xml").build();

        HttpResponse<String> response = HTTP_CLIENT().send(request, HttpResponse.BodyHandlers.ofString());
        System.out.println(response.statusCode());
        System.out.println(response.body());

    }
    
    private void updateSolrDocuments(String json) throws IOException, InterruptedException {
        String uri = SOLR_BASEURL + SOLR_CORE + "/update?commit=true";

        HttpRequest request = HttpRequest.newBuilder().uri(URI.create(uri)).POST(BodyPublishers.ofString(json)) // add
                                                                                                                                                     // request
                                                                                                                                                    // header
                .setHeader("Content-Type", "application/json").build();

        HttpResponse<String> response = HTTP_CLIENT().send(request, HttpResponse.BodyHandlers.ofString());
        System.out.println(response.statusCode());
        System.out.println(response.body());
        
    }
    
    
    // use default solrconfig.xml and add at the bottom:   <schemaFactory class="ClassicIndexSchemaFactory"/>
    
    
    private void initCore(String coreName)  throws IOException, InterruptedException {
        String uriUnload = SOLR_BASEURL + "admin/cores?action=UNLOAD&deleteInstanceDir=true&core=" + coreName;
        HttpRequest requestUnload = HttpRequest.newBuilder().uri(URI.create(uriUnload)).GET()
                .setHeader("User-Agent", "Pica2Solr") // add request header
                .setHeader("Content-Type", "text/xml").build();

        HttpResponse<String> responseUnload = HTTP_CLIENT().send(requestUnload, HttpResponse.BodyHandlers.ofString());
        System.out.println(responseUnload.statusCode());
        System.out.println(responseUnload.body());
        
        String uri = SOLR_BASEURL + "admin/cores?action=CREATE&configSet=pica_analysis&property.update.autoCreateFields=false&name=" + coreName;
        HttpRequest request = HttpRequest.newBuilder().uri(URI.create(uri)).GET()
                .setHeader("User-Agent", "Pica2Solr") // add request header
                .setHeader("Content-Type", "text/xml").build();

        HttpResponse<String> response = HTTP_CLIENT().send(request, HttpResponse.BodyHandlers.ofString());
        System.out.println(response.statusCode());
        System.out.println(response.body());
    }
    
    

}
