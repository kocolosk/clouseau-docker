# Clauseau 2.17.0 docker image for CouchDB 3+

The image created by this Dockerfile will not run on its own, because Clouseau
expects to find EPMD on localhost. It can, however, be used in the CouchDB Helm
chart with the `enableSearch` flag.

## Build

- Build image
  ```
  $ docker build . -t clouseau:2.17.0
  ```

- Push to your ECR

  AWS: https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html

## Install CouchDB with search enabled using helm chart
```
$ helm repo add couchdb https://apache.github.io/couchdb-helm
$ helm install couchdb/couchdb \
  --set image.tag=3.0.0 \
  --set enableSearch=true \
  --set searchImage.name=<your clauseau image> \
  --set searchImage.tag=2.17.0
```
