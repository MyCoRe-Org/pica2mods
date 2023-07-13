package org.mycore.pica2mods.pica2solr.service;

import java.io.IOException;
import java.io.StringReader;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpRequest.BodyPublishers;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class SolrService {

    @Value("${pica2solr.solr_base_url}")
    private String solrBaseURL;

    private static HttpClient HTTP_CLIENT() {
        return HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).connectTimeout(Duration.ofSeconds(30))
            .build();
    }

    public List<String> listCores() throws IOException, InterruptedException {
        String uri = solrBaseURL + "admin/cores?action=STATUS";
        HttpRequest request = HttpRequest.newBuilder().uri(URI.create(uri)).GET()
            .setHeader("User-Agent", "Pica2Solr") // add request header
            .setHeader("Content-Type", "text/xml").build();

        HttpResponse<String> response = HTTP_CLIENT().send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 200) {
            System.err.println("ERROR");
            System.err.println(response.body());
            return List.of();
        } else {
            JsonReader jsonReader = Json.createReader(
                new StringReader(response.body()));
            JsonObject jsonObject = jsonReader.readObject();
            return List.copyOf(jsonObject.getJsonObject("status").keySet());
        }
    }

    public boolean initCore(String name) throws IOException, InterruptedException {
        List<String> cores = listCores();
        if (cores.contains(name)) {
            System.out.println("The Solr core '" + name + "' exists and will be deleted and recreated");
            String uriUnload = solrBaseURL + "admin/cores?action=UNLOAD&deleteInstanceDir=true&core=" + name;
            HttpRequest requestUnload = HttpRequest.newBuilder().uri(URI.create(uriUnload)).GET()
                .setHeader("User-Agent", "Pica2Solr") // add request header
                .setHeader("Content-Type", "text/xml").build();

            HttpResponse<String> responseUnload = HTTP_CLIENT().send(requestUnload,
                HttpResponse.BodyHandlers.ofString());
            if (responseUnload.statusCode() != 200) {
                System.err.println("ERROR");
                System.err.println(responseUnload.body());
            }
        }

        String uri = solrBaseURL
            + "admin/cores?action=CREATE&configSet=pica_analysis&property.update.autoCreateFields=false&name="
            + name;
        HttpRequest request = HttpRequest.newBuilder().uri(URI.create(uri)).GET()
            .setHeader("User-Agent", "Pica2Solr") // add request header
            .setHeader("Content-Type", "text/xml").build();

        HttpResponse<String> response = HTTP_CLIENT().send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 200) {
            System.err.println("ERROR");
            System.err.println(response.body());
            return false;
        }
        return true;
    }

    // http://host:port/solr/core_name/update?commit=true&stream.body=<delete><query>*:*</query></delete>"
    public boolean clearCore(String name) throws IOException, InterruptedException {
        List<String> cores = listCores();
        if (!cores.contains(name)) {
            System.err.println("The Solr core '" + name + "' does not exist.");
            return false;
        }

        String uri = solrBaseURL + name + "/update?commit=true";

        HttpRequest request = HttpRequest.newBuilder().uri(URI.create(uri))
            .POST(BodyPublishers.ofString("<delete><query>*:*</query></delete>"))
            .setHeader("User-Agent", "Pica2Solr") // add request header
            .setHeader("Content-Type", "text/xml").build();

        HttpResponse<String> response = HTTP_CLIENT().send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 200) {
            System.err.println("ERROR");
            System.err.println(response.body());
            return false;
        }
        return true;
    }

    public boolean updateSolrDocuments(String core, String jsonData) throws IOException, InterruptedException {
        String uri = solrBaseURL + core + "/update?commit=true";

        HttpRequest request = HttpRequest.newBuilder().uri(URI.create(uri)).POST(BodyPublishers.ofString(jsonData))
            .setHeader("Content-Type", "application/json").build();
        HttpResponse<String> response = HTTP_CLIENT().send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 200) {
            System.err.println("ERROR");
            System.err.println(response.body());
            return false;
        }
        return true;
    }
}
