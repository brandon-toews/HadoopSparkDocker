#!/bin/bash

apt update && apt upgrade -y

# Start the master in the foreground
exec /opt/spark/bin/spark-class org.apache.spark.deploy.master.Master \
    --host spark-master \
    --port 7077 \
    --webui-port 8080 \
    &

# Start Jupyter notebook with specific directory
jupyter notebook \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root \
    --NotebookApp.notebook_dir='/opt/notebooks' \
    --NotebookApp.token='' \
    --NotebookApp.password=''
