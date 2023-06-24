
remove corrupted bucket from indexer if there is no valid journal.gz file in the bucket. A valid journal.gz file in the bucket is required to rebuild a bucket.

If you have already validate that no journal.gz file exists on any copy of the bucket across the index cluster you can proceed with the steps below. Make sure to remove all copies of that bucket from the peers holding that copy to avoid having the cluster replicate a corrupted bucket again.

If there are copies of the bucket across the cluster which do have journal.gz files you can try and remove the copy of the bucket without the journal.gz file and let the cluster replicate another copy from one of the peers with a good copy.


**This exercise is to remove corrupted buckets from peers:**


**1.)** identify corrupted buckets:

a.)
```| dbinspect index=_internal corruptonly=true | search state!=hot | table bucketId guId```


b.) check splunkd.log for any events indicating journal.gz is missing:

```index=_internal component=BucketReplicator "Could not find size of file" | stats dc(bid) AS bid by host | table host bid```

```05-23-2023 17:03:12.159 +0000 ERROR BucketReplicator [16633 BucketReplicationThread] - Could not find size of file=/opt/sdata2/sendmail_syslog/colddb/rb_1673941043_1673940851_110_A558F492-468C-4422-BFE9-9A1F07FB5B40/rawdata/journal.gz for bid=sendmail_syslog~110~A558F492-468C-4422-BFE9-9A1F07FB5B40. stat() failed. No such file or directory```



**2.)** create a file called bucket_guid.txt listing the bucket and guid of peer which holds the bucket on the cluster manager in $SPLUNK_HOME/bin. These are the buckets and indexer guids where you will remove the buckets from the peer with the remove_from_peer curl command in step 3 below.

ie:

```_internal~76~E691AF05-67D7-45F8-814C-851F260B71B7	E3085D48-FB86-42F3-AC2A-0013AE02E36D```

```_internal~77~E691AF05-67D7-45F8-814C-851F260B71B7	E3085D48-FB86-42F3-AC2A-0013AE02E36D```

```_internal~78~E691AF05-67D7-45F8-814C-851F260B71B7	E3085D48-FB86-42F3-AC2A-0013AE02E36D```


note: You can obtain indexer to guid mapping by running the following search from the monitoring console (replace <label> with the label name of your index cluster):

```| rest /services/server/info  splunk_server_group=dmc_group_indexer splunk_server_group=dmc_indexerclustergroup_<label>    | table splunk_server guid```


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











