MODS2Solr
=========

This tools creates a Solr core from MODS records in a MyCoRe repository.

The core can be used to analyze the frequency and content of certain MODS elements and attributes

The input is downloaded via REST API from a MyCoRe repository.


Installation
------------
### Solr
  - install Solr on your local machine
    (tested with the latest Solr versions of 8.x and 9.x)
  - deploy the config set folder to /{solr-install-dir}/server/solr/configsets
  - start/restart the Solr server

### Appplication
The tool itself is provided as Java application (in a single JAR file).


Running
-------
First make sure that your local Solr server is running (default URL: http://localhost:8983).

You may use the following command line arguments:

### Managing Solr
#### List all available Solr cores
```
java -jar mods2solr.jar list-cores
```

#### Initialize a new Solr core
```
java -jar mods2solr.jar init-core <name>
```

#### Delete the content of an existing Solr core
```
java -jar mods2solr.jar clear-core <name>
```

### Adding MODS data to Solr core
#### Run with default parameters
```
java -jar mods2solr.jar run
```
#### Run with modified parameters
```
java -jar mods2solr.jar run --solr_core=mods_mycore --mycore_rest_objects=https://www.mycore.org/mir/api/v1/objects --resume_id=mir_mods_00000100
```

| Parameter | Description                                                      |
| --------  | --------------------------------------------------------------- |
| `solr_core` | the name of the Solr core                                        |
| `mycore_rest_objects` | the MyCoRe REST API URL for object listing                     |
| `resume_id` | the MyCoRe ObjectID where a previously stopped import should be resumed |