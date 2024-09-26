#!/bin/bash
# failover.sh: Promotes a replica to primary if the primary fails

failed_node_id=$1
old_primary_node_id=$2 
new_primary_hostname=$3

# Promote the new replica to primary
if [ $new_primary_hostname ]; then
    echo "Promoting replica $new_primary_hostname to primary..."
    # Does not require postgres superuser
    docker exec -t $new_primary_hostname pg_ctl promote -D /var/lib/postgresql/data
    echo "Replica $new_primary_node_id promoted to primary."
fi
