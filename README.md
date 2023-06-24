
remove corrupted bucket from indexer if there is no valid journal.gz file in the bucket. A valid journal.gz file in the bucket is required to rebuild a bucket.

If you have already validate that no journal.gz file exists on any copy of the bucket across the index cluster you can proceed with the steps below.

**This exercise is to remove corrupted buckets from peers:**


**1.)** identify corrupted buckets with dbinspect:

```| dbinspect index=_internal corruptonly=true | search state!=hot | table bucketId guId```


**2.)** create a file called bucket_guid.txt listing the bucket and guid of peer which holds the bucket on the cluster manager in $SPLUNK_HOME/bin

ie:

```_internal~76~E691AF05-67D7-45F8-814C-851F260B71B7	E3085D48-FB86-42F3-AC2A-0013AE02E36D```

```_internal~77~E691AF05-67D7-45F8-814C-851F260B71B7	E3085D48-FB86-42F3-AC2A-0013AE02E36D```

```_internal~78~E691AF05-67D7-45F8-814C-851F260B71B7	E3085D48-FB86-42F3-AC2A-0013AE02E36D```

**3.)** create remove_bucket.sh script on the cluster manager in $SPLUNK_HOME/bin

```
#!/bin/bash
set -x
# Read values from the file
while IFS=$'\t' read -r bucket guid; do
    # Replace "bucket" with the bucket and "guid" with the guid in the curl command
    command="curl -k -u admin:password https://localhost:8089/services/cluster/manager/buckets/${bucket}/remove_from_peer -X POST -d peer=${guid}"
    # Execute the curl command
    eval "$command"
done < bucket_guid.txt
```

**4.)** put the CM into maintenance mode:

```./splunk enable maintenance-mode```

**5.)** run the script to remove buckets from peer:

```./remove_bucket.sh```


**6.)** Once all corrupted buckets have been removed from all peers, take the CM out of maintenance mode:

```./splunk disable maintenance-mode```











