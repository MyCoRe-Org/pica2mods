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
$ git tag -a v2.13 -m "new tag"
$ git push origin v2.13
```

### Perform the release
- using a Maven profile (`-P`) with login settings for Sonatype

```
$ mvn release:perform -Psign-with-gpg -Pdeploy-to-sonatype
```
- wait... (last time it took about 12 min)

### Finishing
- remove release config files
- merge modified POM files back to develop

```
$ mvn release:clean

$ git checkout develop
$ git merge --no-ff main
$ git push origin develop
```

### Check successful deployment
- on Sonatype:  
  <https://central.sonatype.com/artifact/org.mycore.pica2mods/pica2mods-xslt>
- later on Maven Central  
  (synchronization with Maven Central can take up to 24 h):  
  <https://mvnrepository.com/artifact/org.mycore.pica2mods/pica2mods-xslt>
