FROM registry.redhat.io/ubi8/ubi-minimal

ARG VERSION=2.21.6
ARG APP_ROOT=/opt/couchdb-search

ENV JAVA_MAJOR_VERSION=8 \
    JAVA_HOME=/usr/lib/jvm/jre-1.8.0 \
    CLASSPATH=${APP_ROOT}/lib/* \
    SLF4J_VERSION=2.0.7

RUN microdnf install java-1.8.0-openjdk-headless && \
    microdnf clean all

RUN mkdir -p ${APP_ROOT}/etc ${APP_ROOT}/lib ${APP_ROOT}/data
COPY clouseau.ini jmxremote.password ${APP_ROOT}/etc/
COPY clouseau-${VERSION}.jar ${APP_ROOT}/lib/
COPY target/dependency/*.jar ${APP_ROOT}/lib/

RUN rm ${APP_ROOT}/lib/slf4j-api-*
RUN rm ${APP_ROOT}/lib/slf4j-simple-*
COPY slf4j-api-${SLF4J_VERSION}.jar ${APP_ROOT}/lib/
COPy slf4j-simple-${SLF4J_VERSION}.jar ${APP_ROOT}/lib/

RUN chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} && \
    chmod 660 ${APP_ROOT}/etc/jmxremote.password

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
    # "-Dcom.sun.management.jmxremote", \
    # "-Dcom.sun.management.jmxremote.port=9090", \
    # "-Dcom.sun.management.jmxremote.local.only=false", \
    # "-Dcom.sun.management.jmxremote.authenticate=true", \
    # "-Dcom.sun.management.jmxremote.password.file=/opt/couchdb-search/etc/jmxremote.password", \
    "-Dcom.sun.management.jmxremote.ssl=false", \
    "-XX:OnOutOfMemoryError=\"kill -9 %p\"", \
    "-XX:+UseConcMarkSweepGC", \
    "-XX:+CMSParallelRemarkEnabled", \
    "com.cloudant.clouseau.Main", \
    "/opt/couchdb-search/etc/clouseau.ini" \
]
