#!/bin/bash

until pg_isready -h postgres-primary -p 5432; do echo waiting for master; sleep 2; done;

pg_ctl stop -D /var/lib/postgresql/data

if [ "$(ls -A /var/lib/postgresql/data)" ]; then
    echo "Removing existing data"
    rm -rf /var/lib/postgresql/data/*
fi

echo "Init basebackup"
pg_basebackup -h postgres-primary -U replication_user -D /var/lib/postgresql/data --dbname=postgres://replication_user:$(cat /run/secrets/replication_password)@postgres-primary:5432/topaz -Fp -Xs -P -R

touch /var/lib/postgresql/data/standby.signal

cp /etc/postgresql/postgresql.conf /var/lib/postgresql/data/postgresql.conf
cp /etc/postgresql/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf

pg_ctl start -D /var/lib/postgresql/data

pg_ctl reload
echo "Done init-replica.sh."
