#!/bin/bash

#
# /usr/local/bin/start.sh
# Start Elasticsearch, Logstash and Kibana services
#

# Replace environment variables in logstash configuration (doesn't support ENV)
sed -i "s/{{REDIS_HOST}}/$REDIS_HOST/g" /etc/logstash/conf.d/10-input.conf
sed -i "s/{{REDIS_HOST}}/$REDIS_HOST/g" /etc/logstash/conf.d/20-filter.conf
sed -i "s/{{REDIS_HOST}}/$REDIS_HOST/g" /etc/logstash/conf.d/30-output.conf
sed -i "s/{{REDIS_PORT}}/$REDIS_PORT/g" /etc/logstash/conf.d/10-input.conf
sed -i "s/{{REDIS_PORT}}/$REDIS_PORT/g" /etc/logstash/conf.d/20-filter.conf
sed -i "s/{{REDIS_PORT}}/$REDIS_PORT/g" /etc/logstash/conf.d/30-output.conf

# Start elasticsearch and logstash
service elasticsearch start
service logstash start

# wait for elasticsearch to start up
# see: https://github.com/elasticsearch/kibana/issues/3077
counter=0;
while [ ! "$(curl localhost:9200 2> /dev/null)" -a $counter -lt 30  ]; do
  sleep 1;
  ((counter++));
  echo "waiting for Elasticsearch to be up ($counter/30)";
done;

# Start kibana
service kibana4 start

tail -f /var/log/elasticsearch/elasticsearch.log
