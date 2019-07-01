This repo is very much a work in progress.

The Dockerfile expects to find all dependency JARs in the target/dependency/
folder. One way to achieve this is

```
ln -s /path/to/clouseau/pom.xml .
mvn dependency:copy-dependencies
```

The image created by this Dockerfile will not run on its own, because Clouseau
expects to find EPMD on localhost. It can, however, be used in the CouchDB Helm
chart with the `enableSearch` flag.
