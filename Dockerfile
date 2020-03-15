ARG VERSION=2.17.0

# Clouseau & Deps

FROM maven
RUN git clone --depth=1 https://github.com/cloudant-labs/clouseau && \
    cd clouseau && \
    mvn dependency:copy-dependencies && \
    mvn dependency:get \
        -Dartifact=com.cloudant:clouseau:2.17.0 \
        -DremoteRepositories=https://maven.cloudant.com/repo \
        -Ddest=./target/dependency/

# Main Image

FROM registry.access.redhat.com/ubi8/ubi-minimal

ARG APP_ROOT=/opt/couchdb-search

ENV JAVA_MAJOR_VERSION=8 \
    JAVA_HOME=/usr/lib/jvm/jre-1.8.0 \
    CLASSPATH=${APP_ROOT}/lib/*

RUN microdnf install java-1.8.0-openjdk-headless && \
    microdnf clean all

RUN mkdir -p ${APP_ROOT}/etc ${APP_ROOT}/lib ${APP_ROOT}/data
COPY clouseau.ini log4j.properties ${APP_ROOT}/etc/
# COPY clouseau-${VERSION}.jar ${APP_ROOT}/lib/
COPY --from=0 /clouseau/target/dependency/*.jar ${APP_ROOT}/lib/

RUN chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT}

EXPOSE 9090

USER 5984
WORKDIR ${APP_ROOT}
VOLUME ${APP_ROOT}/data

ENTRYPOINT ["java"]
CMD [ \
    "-server", \
    "-Xmx2G", \
    "-Dsun.net.inetaddr.ttl=30", \
    "-Dsun.net.inetaddr.negative.ttl=30", \
    "-Dlog4j.configuration=file:/opt/couchdb-search/etc/log4j.properties", \
    "-XX:OnOutOfMemoryError=\"kill -9 %p\"", \
    "-XX:+UseConcMarkSweepGC", \
    "-XX:+CMSParallelRemarkEnabled", \
    "com.cloudant.clouseau.Main", \
    "/opt/couchdb-search/etc/clouseau.ini" \
]
