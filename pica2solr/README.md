Pica2Solr
=========

This tools creates a Solr core from Pica catalog records.

The core can be used to analyze the frequency and content of certain Pica fields.

The input is based on an SRU query to a GBV catalog. The input format is PicaXML.


Installation
------------
### Solr
  - install Solr (tested with the latest Solr 8 version) on your local machine
  - deploy the config set folder to /{solr-install-dir}/server/solr/configsets
  - start/restart the Solr server

### Appplication
The tool itself is provided as Java application (in a single JAR file).


Running
-------
First make sure that your local server is running (default URL: http://localhost:8983).

You may use the following command line arguments:

### Managing Solr
#### List all available Solr cores
```
java -jar pica2solr.jar list-cores
```

#### Initialize a new Solr core
```
java -jar pica2solr.jar init-core <name>
```

#### Delete the content of an existing Solr core
```
java -jar pica2solr.jar clear-core <name>
```

### Adding catalog data to Solr core
#### Run with default parameters
```
java -jar pica2solr.jar run
```   
#### Run with modified parameters
```
java -jar pica2solr.jar run --solr_core=picaX --sru_catalog=opac-de-28 --sru_query=pica.all%3Dmycore --library_id=62
```   

