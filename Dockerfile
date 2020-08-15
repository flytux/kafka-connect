FROM confluentinc/cp-kafka-connect:5.5.0


ENV DEBEZIUM_VERSION=1.3.0-SNAPSHOT \
    MAVEN_OSS_SNAPSHOT="https://oss.sonatype.org/content/repositories/snapshots" \
    KAFKA_CONNECT_PLUGINS_DIR=/usr/share/java/kafka-connector-jdbc

USER root

RUN echo "===> Installing MySQL connector" \
    && curl https://repo1.maven.org/maven2/mysql/mysql_connector-java/8.0.19/mysql-connector-java-8.0.19.jar --output /usr/share/java/kafka-connect-jdbc/mysql-connector-java-8.0.19.jar
RUN echo "==> Installing connector plugins" \
    && confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:5.5.0 && confluent-hub install --no-prompt confluentinc/kafka-connect-datagen:0.3.2
RUN echo "==> Downloading JDBC drivers" \
    && cd /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib \
    && curl https://maven.xwiki.org/externals/com/oracle/jdbc/ojdbc8/12.2.0.1/ojdbc8-12.2.0.1.jar -o ojdbc8-12.2.0.1.jar \
    && cp ojdbc8-12.2.0.1.jar /usr/share/java/kafka-connect-jdbc/

RUN echo "==> Install Debezium Oracle connector and required libraries" \
    && wget "https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=io.debezium&a=debezium-connector-oracle&v=LATEST&c=plugin&e=tar.gz" -O /tmp/dbz-ora.tgz \
    && tar -xvf /tmp/dbz-ora.tgz --directory /usr/share/java/

RUN echo "==> Install Debezium Postgres connector and required libraries" \
    && wget "https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=io.debezium&a=debezium-connector-postgres&v=LATEST&c=plugin&e=tar.gz" -O /tmp/dbz-pgs.tgz \
    && tar -xvf /tmp/dbz-pgs.tgz --directory /usr/share/java/

RUN echo "==> Install Debezium Mysql connector and required libraries" \
    && wget "https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=io.debezium&a=debezium-connector-mysql&v=LATEST&c=plugin&e=tar.gz" -O /tmp/dbz-mys.tgz \
    && tar -xvf /tmp/dbz-mys.tgz --directory /usr/share/java/

RUN echo "==> Install Debezium Mongo connector and required libraries" \
    && wget "https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=io.debezium&a=debezium-connector-mongodb&v=LATEST&c=plugin&e=tar.gz" -O /tmp/dbz-mon.tgz \
    && tar -xvf /tmp/dbz-mon.tgz --directory /usr/share/java/

RUN echo "==> Install Debezium SQLserver connector and required libraries" \
    && wget "https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=io.debezium&a=debezium-connector-sqlserver&v=LATEST&c=plugin&e=tar.gz" -O /tmp/dbz-sql.tgz \
    && tar -xvf /tmp/dbz-sql.tgz --directory /usr/share/java/

RUN echo "===> Install the required library files" \
    && apt-get update \
    && apt-get install -y --force-yes unzip libaio1 
COPY instantclient_12_2 /usr/share/java/debezium-connector-oracle/ 
COPY instantclient_12_2/ojdbc8.jar /usr/share/java/kafka-connect-jdbc/


