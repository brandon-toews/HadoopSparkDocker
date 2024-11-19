#!/bin/bash

set -e

apt update && apt upgrade -y

# Wait for namenode to be up
until curl -sf "http://namenode:9870"; do
    echo "Waiting for namenode..."
    sleep 5
done

# Start Hadoop services
echo "Starting Hadoop DataNode..."
su hadoop -c "hdfs datanode" &

echo "Starting Hadoop NodeManager..."
su hadoop -c "yarn nodemanager"