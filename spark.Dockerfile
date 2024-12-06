FROM openjdk:11-jdk-slim

# Install required packages
RUN apt-get update && \
    apt-get install -y \
    curl \
    tini \
    procps \
    net-tools \
    python3 \
    python3-pip \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Set Spark version
ENV SPARK_VERSION=3.5.0
ENV HADOOP_VERSION=3

# Download and install Spark
RUN curl -sL "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" \
    | tar -xz -C /opt/ \
    && ln -sf /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /opt/spark

# Set environment variables
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

# Create directory for logs
RUN mkdir -p $SPARK_HOME/logs

WORKDIR $SPARK_HOME

# Copy all scripts into the image
COPY ./scripts/spark/ /opt/scripts/
RUN chmod +x /opt/scripts/*
COPY ./config/spark/log4j2.properties /opt/spark/conf/log4j2.properties

ENTRYPOINT ["/usr/bin/tini", "--"]
# Dynamic startup script
CMD ["/bin/bash", "-c", "/opt/scripts/$START_SCRIPT"]
# CMD ["/master.sh"]