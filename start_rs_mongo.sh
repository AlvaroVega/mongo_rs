#!/bin/bash

if [ ! "$1" == "-f" ] ; then

    echo "This is a script only for development environments."
    echo "Are you sure you want start a local replicaset for MongoDB? "
    echo "Mongo db should not be started"
    echo "(Y/N): "
    read answer
    case "$answer" in
        Y|y ) echo "Executing"
            ;;
        * ) echo "Exiting"
            exit
            ;;
    esac
fi

host=`uname -n`
#echo "host=$host"

mkdir -p /var/tmp/mongodb/
mkdir -p /var/tmp/mongodb/rs_mongo-0
mkdir -p /var/tmp/mongodb/rs_mongo-1
mkdir -p /var/tmp/mongodb/rs_mongo-2

echo "[MONGO] Stoping mongodb service"
sudo su -s /bin/sh -c '/etc/init.d/mongod stop'

echo "[MONGO] Starting two nodes instances in $host for replicast 'rs_mongo'"
sudo su -s /bin/sh -c 'nohup mongod --port 27017 --dbpath /var/tmp/mongodb/rs_mongo-0 --replSet rs_mongo --smallfiles --oplogSize 128 > /var/tmp/mongodb/rs_mongo-0/output.log &'
sudo su -s /bin/sh -c 'nohup mongod --port 27018 --dbpath /var/tmp/mongodb/rs_mongo-1 --replSet rs_mongo --smallfiles --oplogSize 128 > /var/tmp/mongodb/rs_mongo-1/output.log &'
sudo su -s /bin/sh -c 'nohup mongod --port 27019 --dbpath /var/tmp/mongodb/rs_mongo-2 --replSet rs_mongo --smallfiles --oplogSize 128 > /var/tmp/mongodb/rs_mongo-1/output.log &'

sleep 5
echo "[MONGO] Configuring replicaset"

function start_replicaset() {
    mongo <<EOF
    rs.initiate()
    rs.add("$host:27018")
    rs.add("$host:27019")
    rs.status()
EOF
}

start_replicaset



