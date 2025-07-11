How to Release a new Pica2MODS version
======================================

### Merge changes from develop branch to main
```
$ git checkout main
$ git pull
$ git merge --no-ff develop

```

### Prepare the release
- create a new version
- push new version tag to Github

```
$ mvn release:prepare
$ git push origin main
$ git push origin v1.2
```

### Perform the release
- using a Maven profile (`-P`) with login settings for Sonatype

```
$ mvn release:perform -Pdeploy-to-sonatype
```
### Finishing
- remove release config files
- merge modified POM files back to develop

```
$ mvn release:clean

$ git checkout develop
$ git merge --no-ff main
$ git push origin develop
```

### Chechk successful deployment
- on Sonatype:  
  <https://oss.sonatype.org/#nexus-search;quick~pica2mods>
- later on Maven Central  
  (synchronization with Maven Central can take up to 24 h):  
  <https://mvnrepository.com/artifact/org.mycore.pica2mods>
