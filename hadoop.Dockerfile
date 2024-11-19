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

# Create hadoop user and group first
RUN groupadd -r hadoop && \
    useradd -r -g hadoop -m -s /bin/bash hadoop

ARG CONTAINER_VOLUME=none

# Set Hadoop version
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
ENV CONTAINER_VOLUME=$CONTAINER_VOLUME

# Download and install Hadoop
RUN curl -sL "https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
    | tar -xz -C /opt/ \
    && ln -sf /opt/hadoop-${HADOOP_VERSION} /opt/hadoop

# Create necessary directories
RUN mkdir -p $CONTAINER_VOLUME \
    && mkdir -p $HADOOP_HOME/logs \
    && mkdir -p /var/log/hadoop

# Set ownership and permissions
RUN chown -R hadoop:hadoop $HADOOP_HOME \
    && chown -R hadoop:hadoop /hadoop \
    && chown -R hadoop:hadoop /var/log/hadoop \
    && chown -R hadoop:hadoop $HADOOP_HOME/logs \
    && chmod -R 755 $HADOOP_HOME/logs

# Copy Hadoop configuration files
COPY --chown=hadoop:hadoop config/*.xml $HADOOP_CONF_DIR

# Copy all scripts into the image
COPY ./scripts/hadoop/ /opt/scripts/
RUN chmod +x /opt/scripts/*

ENTRYPOINT ["/usr/bin/tini", "--"]
# Dynamic startup script
CMD ["/bin/bash", "-c", "/opt/scripts/$START_SCRIPT"]