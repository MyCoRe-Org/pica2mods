# How to Release a new Pica2MODS version

## Branching model

**Pica2MODS** uses a lightweight model between *git-flow* and *trunk-based development*. \
It is not strict *git-flow*: there are no `release/*` branches for regular releases.

| Branch | Purpose |
| --- | --- |
| `develop` | Ongoing development, always a `-SNAPSHOT` version. <br>Every push deploys a snapshot to Sonatype. |
| `main` | Release line. `develop` is merged into it before each release; <br>the release commits are made here. |
| Release tags <br>`vX.Y` | (e.g. `v3.0`).  Only tags; release branches are created on demand, <br>if fixes for a previous (major-) version are necessary |


## Regular release via (GitHub Actions)

The workflow `.github/workflows/maven-release.yml` automates the whole process.

### Start

GitHub → *Actions* → *Maven Release* → *Run workflow*
> run the version from `develop` branch\
> (it contains the latest changes of the workflow)

| Input | Default |
| --- | --- |
| `releaseVersion` | current version without `-SNAPSHOT` (e.g. `3.1`) |
| `developmentVersion` | next minor `-SNAPSHOT` (e.g. `3.2-SNAPSHOT`) |
| `createGithubRelease` | `true` (GitHub release with generated notes) |

### Publish the Release

The release is uploaded to Sontatype only.\
(automatic publishing is disabled for the release plugin in `pom.xml`)

- Login into [https://central.sonatype.com](https://central.sonatype.com/)
- check the uploaded files, and
- push the `Publish` button and wait

### What the workflow does

1. Merge `develop` into `main` (`--no-ff`)
2. `mvn release:prepare` – set release version, create tag `vX.Y`, set next `-SNAPSHOT` version (nothing is pushed yet)
3. `mvn release:perform` – build the tag, sign with GPG and upload via Sonatype `central-publishing-maven-plugin` (profiles `sign-with-gpg`, `deploy-to-sonatype`)
4. Push `main` and the tag – only after a successful deployment
5. Merge `main` back into `develop` and push
6. optionally Create a GitHub release

If the run fails before step 4, nothing has been pushed
– simply fix the cause and run it again.

#### Notes
- The `maven-release-plugin` creates two commits on `main`: *prepare release vX.Y* and *prepare for next development iteration*.  
  As a consequence the tip of `main` carries the next `-SNAPSHOT` version, not the released one.  
  To build exactly the released state, check out the tag.
- After a release, `main` is merged back into `develop` 
  > never recreate `develop` from `main`:  
  > this would drop commits made on `develop` in the meantime
  > and close open pull requests).
- This follows the release model of the `maven-release-plugin` itself and the *release from trunk / branch for release late* pattern of *trunk-based development*: 
  release branches are created on-demand from a tag, when a fix is actually needed.

## Manual release (fallback only)
```
$ git checkout main
$ git pull
$ git merge --no-ff develop

$ mvn release:prepare -DtagNameFormat=v@{project.version} -DpushChanges=false
$ mvn release:perform -DlocalCheckout=true -Psign-with-gpg -Pdeploy-to-sonatype

$ git push origin main
$ git push origin vX.Y

$ git checkout develop
$ git pull
$ git merge main
$ git push origin develop
```
- If automatic publishing is configured in pom.xml it can take up to 15 min until the `mvn release:perform` finishes.
- If something goes wrong locally, `mvn release:rollback` or `mvn release:clean` removes the release configuration files.

## Check successful deployment

- on Sonatype: <https://central.sonatype.com/artifact/org.mycore.pica2mods/pica2mods-xslt>
- later on Maven Central (synchronization with Maven Central can take up to 24 h): 
  <https://mvnrepository.com/artifact/org.mycore.pica2mods/pica2mods-xslt>
