FROM dockerfile/ubuntu

MAINTAINER tim@magnetic.io

# This Dockerfile packages all Vamp components in one container. The resulting container can be used for basic testing
# kicking the tires. It is not meant for production or any other serious work.
# For more info, see the accompanying README.md and mesos_bootstrap.sh script


# Install Java 8
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle


# Get Vamp-Core
RUN wget https://bintray.com/artifact/download/magnetic-io/downloads/vamp-core/core-assembly-0.7.0-RC1.jar

# Get Vamp-Pulse
RUN wget https://bintray.com/artifact/download/magnetic-io/downloads/vamp-pulse/pulse-assembly-0.7.0-RC1.jar

# Get Vamp-Router
RUN wget https://bintray.com/artifact/download/magnetic-io/downloads/vamp-router/vamp-router_0.7.1-RC1_linux_386.zip && \
    unzip vamp-router_0.7.1-RC1_linux_386.zip

# Install Haproxy & Supervisor

RUN add-apt-repository -y ppa:vbernat/haproxy-1.5 && \
    apt-get update && \
    apt-get install -y haproxy supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY vamp-core.conf /root/vamp-core.conf

COPY logback.xml /root/logback.xml

# expose the Vamp-Core port
EXPOSE 8080

# expose the Vamp-Pulse port
EXPOSE 8083

# expose the Vamp-Router port
EXPOSE 10001

# expose the HAproxy port
EXPOSE 1980

# expose Elastic search
EXPOSE 9200

CMD ["/usr/bin/supervisord"]
