FROM centos:8

LABEL maintainer="Ilija Vukotic <ivukotic@cern.ch>"

RUN dnf update -y

RUN  dnf list installed

RUN dnf install -y epel-release.noarch

RUN dnf update -y

# Install dependencies
RUN dnf install -y \
    httpd \
    git \
    # curl \
    wget \
    rsync \
    zip \
    unzip \
    vim \
    libaio \
    python3 \
    # ntp \
    krb5-workstation \
    # mod_auth_kerb \
    mod_ssl \
    # mod_wsgi \
    openssl-devel \
    java-1.8.0-openjdk-devel 

#     mysql-connector-java
#     build-essential \
#     krb5-user \
#     libzmq3-dev \
#     pkg-config \
#     software-properties-common \
#     zlib1g-dev 
#   module-init-tools \

#   openjdk-8-jdk \
#   openjdk-8-jre-headless \

ENV JAVA_HOME /etc/alternatives/java_sdk_1.8.0_openjdk/jre/

# # es-hadoop - for all the modules (pig, mr, spark)
ENV EH_VERSION 7.12.0
RUN curl -LO https://artifacts.elastic.co/downloads/elasticsearch-hadoop/elasticsearch-hadoop-$EH_VERSION.zip
RUN unzip elasticsearch-hadoop-$EH_VERSION.zip && \
    rm elasticsearch-hadoop-$EH_VERSION.zip
RUN mkdir /elasticsearch-hadoop && \
    ln -s /elasticsearch-hadoop-$EH_VERSION/dist/elasticsearch-hadoop-$EH_VERSION.jar /elasticsearch-hadoop/elasticsearch-hadoop.jar && \
    ln -s /elasticsearch-hadoop-$EH_VERSION/dist/elasticsearch-hadoop-pig-$EH_VERSION.jar /elasticsearch-hadoop/elasticsearch-hadoop-pig.jar && \
    ln -s /elasticsearch-hadoop-$EH_VERSION/dist/elasticsearch-spark-20_2.11-$EH_VERSION.jar /elasticsearch-hadoop/elasticsearch-spark.jar

# hdfs - now needs subsription
# RUN wget http://archive.cloudera.com/cdh5/one-click-install/redhat/7/x86_64/cloudera-cdh-5-0.x86_64.rpm
# RUN yum install -y localinstall cloudera-cdh-5-0.x86_64.rpm

# RUN yum install -y pig \
#     hbase \
#     flume-ng 

# # elephant-bird
# ENV EB_VERSION 4.17
# RUN wget http://central.maven.org/maven2/com/twitter/elephantbird/elephant-bird-hadoop-compat/$EB_VERSION/elephant-bird-hadoop-compat-$EB_VERSION.jar -O /usr/lib/pig/lib/elephant-bird-hadoop-compat.jar
# RUN wget http://central.maven.org/maven2/com/twitter/elephantbird/elephant-bird-core/$EB_VERSION/elephant-bird-core-$EB_VERSION.jar -O /usr/lib/pig/lib/elephant-bird-core.jar
# RUN wget http://central.maven.org/maven2/com/twitter/elephantbird/elephant-bird-pig/$EB_VERSION/elephant-bird-pig-$EB_VERSION.jar -O /usr/lib/pig/lib/elephant-bird-pig.jar

# mysql 
RUN mkdir -p /usr/local/mysql && \
    wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.13/mysql-connector-java-8.0.13.jar -O /usr/local/mysql/mysql-connector-java-8.0.13.jar
# RUN cp /usr/local/mysql/mysql-connector-java-5.1.45-bin.jar /usr/local/sqoop

ENV HADOOP_MAPRED_HOME /usr/lib/hadoop-mapreduce
ENV HADOOP_COMMON_HOME /usr/lib/hadoop

COPY configs/core-site.xml configs/hdfs-site.xml configs/mapred-site.xml configs/yarn-site.xml /etc/hadoop/conf/

COPY Unconfirmed.zip /usr/local/sqoop/lib/ojdbc6.jar
RUN chmod 755 /usr/local/sqoop/lib/ojdbc6.jar

# Oracle
RUN mkdir -p /opt/oracle/
COPY instantclient-basiclite-linux.x64-21.1.0.0.0.zip .
RUN unzip instantclient-basiclite-linux.x64-21.1.0.0.0.zip -d /opt/oracle/
RUN echo /opt/oracle/instantclient_21_1 > /etc/ld.so.conf.d/oracle-instantclient.conf

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install --no-cache-dir \
    h5py \
    tables \
    numpy \
    pandas \
    scipy \
    sklearn \
    elasticsearch \
    cx_Oracle \
    requests \
    mysql-connector \
    stomp.py

COPY configs/krb5.conf /etc/krb5.conf

RUN useradd -ms /bin/bash analyticssvc

USER analyticssvc
WORKDIR /home/analyticssvc

CMD ["sleep", "99999999"]
