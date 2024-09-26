#!/bin/bash
# failback.sh: Reintegrate a node as a replica after recovery.

failed_node_id=$1
old_primary_node_id=$2
new_primary_hostname=$3

#REPLICATION_PASSWORD=$(cat /run/secrets/replication_pass)

# Restore the failed primary as a replica.
if [ $failed_node_id == 0 ]; then
    # postgres-primary is node id 0
    echo "Reintegrating old primary as replica..."
    docker exec -t postgres-primary PGPASSWORD=$(cat /run/secrets/replication_password) pg_basebackup -h $new_primary_hostname -D /var/lib/postgresql/data --username=replication_user --wal-method=stream
    touch /var/lib/postgresql/data/postgres.auto.conf
    echo "primary_conninfo = 'host=$new_primary_hostname user=replication_user password=$REPLICATION_PASSWORD'" > /var/lib/postgresql/data/postgres.auto.conf
    docker restart postgres-primary
    echo "Old primary is now a replica."
fi
