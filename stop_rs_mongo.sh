#!/bin/bash

if [ ! "$1" == "-f" ] ; then

    echo "This is a script only for development environments."
    echo "Are you sure you want start to stop local replicaset for MongoDB? (Y/N): "
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


function stop_replicaset() {
    mongo <<EOF
    rs.remove("$host:27018")
    rs.remove("$host:27019")
EOF
}


echo "[MONGO] Stopping replicaset"
stop_replicaset

sleep 5

echo "[MONGO] Killing mongos"
mongors_pid=`ps -ef | grep /var/tmp/mongodb/rs_mongoiot | grep replSet| awk '{ print $2}' `
sudo kill -9 $mongors_pid

sudo rm /tmp/mongodb-27017.sock
sudo rm /tmp/mongodb-27018.sock
sudo rm /tmp/mongodb-27019.sock 

echo "[MONGO] Starting mongodb service"
sudo su -s /bin/sh -c '/etc/init.d/mongod start'

