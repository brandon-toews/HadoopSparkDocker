#!/bin/bash

apt update && apt upgrade -y

pip3 install numpy pandas

# Start the master in the foreground
exec /opt/spark/bin/spark-class org.apache.spark.deploy.master.Master \
    --host spark-master \
    --port 7077 \
    --webui-port 8080
