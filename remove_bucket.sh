#!/bin/bash
set -x
# Read values from the file
while IFS=$'\t' read -r bucket guid; do
    # Replace "bucket" with the bucket and "guid" with the guid in the curl command
    command="curl -k -u admin:password https://localhost:8089/services/cluster/manager/buckets/${bucket}/remove_from_peer -X POST -d peer=${guid}"
    # Execute the curl command
    eval "$command"
done < bucket_guid.txt
