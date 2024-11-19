#!/bin/bash

set -e

apt update && apt upgrade -y

# Format the NameNode if not already formatted
if [ ! -d /hadoop/dfs/name/current ]; then
    echo "Formatting HDFS NameNode..."
    su hadoop -c "hdfs namenode -format -force"
else
    echo "HDFS NameNode already formatted."
fi

# Start Hadoop services
echo "Starting Hadoop NameNode..."
su hadoop -c "hdfs namenode" &

echo "Starting Hadoop ResourceManager..."
su hadoop -c "yarn resourcemanager" &

mkdir -p /home/hadoop/scripts

chown -R hadoop:hadoop /home/hadoop/scripts

tail -f /dev/null

