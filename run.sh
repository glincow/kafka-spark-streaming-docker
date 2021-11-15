#!/bin/bash

# Create and activate a virtual environment then install pyspark and kafka-python
python3 -m venv venv && \
 source venv/bin/activate && \
 pip3 install pyspark kafka-python

# Download dependencies for nodejs apps
cd nodejs-consumer && npm install
cd nodejs-producer && npm install

# Create the jars directory for packaged app
mkdir jars_dir

# Change the directory permission
sudo chmod 777 jars_dir

# Start zookeeper, kafka, spark master and two spark workers
docker-compose up -d

# Wait for installation to complete
sleep 7

# Create jar file and copy it into jars_dir
cd spark-streaming/scala && \
 sbt package && \
 cp target/scala-2.12/spark-streaming-with-kafka_2.12-1.0.jar ../../jars_dir/

# Execute the application with spark-submit
docker exec -it spark \
spark-submit \
--packages "org.apache.spark:spark-sql-kafka-0-10_2.12:3.2.0" \
--master "spark://172.18.0.10:7077" \
--class Streaming \
--conf spark.jars.ivy=/opt/bitnami/spark/ivy \
ivy/spark-streaming-with-kafka_2.12-1.0.jar