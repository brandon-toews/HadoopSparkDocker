#!/bin/bash

apt update && apt upgrade -y

# Start the worker in the foreground
exec /opt/spark/bin/spark-class org.apache.spark.deploy.worker.Worker \
    spark://spark-master:7077
