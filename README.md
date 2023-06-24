
remove corrupted bucket from indexer if there is no valid journal.gz file in the bucket

1.)identify corrupted buckets with dbinspect:
| dbinspect index=_internal corruptonly=true | search state!=hot | table bucketId guId




