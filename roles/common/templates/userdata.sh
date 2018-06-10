#!/bin/bash
set -o errexit
set -o xtrace
apt-get -y update
apt-get -y install apt-transport-https openjdk-8-jre-headless uuid-runtime pwgen

# Install MongoDB
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list
apt-get update
apt-get install -y mongodb-org
systemctl daemon-reload
systemctl enable mongod.service
systemctl restart mongod.service

# Install ElasticSearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list
apt-get update && apt-get install elasticsearch
sed -i -e 's/#cluster.name: my-application/cluster.name: graylog/g' /etc/elasticsearch/elasticsearch.yml
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl restart elasticsearch.service

# Install Graylog
wget https://packages.graylog2.org/repo/packages/graylog-2.4-repository_latest.deb
dpkg -i graylog-2.4-repository_latest.deb
apt-get update && apt-get install graylog-server
sed -i -e "s/password_secret =.*/password_secret = $(pwgen -s 128 1)/" /etc/graylog/server/server.conf
 sed -i -e "s/root_password_sha2 =.*/root_password_sha2 = $(echo -n 'password' | shasum -a 256 | cut -d' ' -f1)/" /etc/graylog/server/server.conf
sed -i -e "s|rest_listen_uri = http://127.0.0.1:9000/api/|rest_listen_uri = http://$(ip route get 8.8.8.8 | awk '{print $NF; exit}'):9000/api/|g" /etc/graylog/server/server.conf
sed -i -e "s|#web_listen_uri = http://127.0.0.1:9000/|web_listen_uri = http://$(ip route get 8.8.8.8 | awk '{print $NF; exit}'):9000/|g" /etc/graylog/server/server.conf         
systemctl daemon-reload
systemctl enable graylog-server.service
systemctl start graylog-server.service