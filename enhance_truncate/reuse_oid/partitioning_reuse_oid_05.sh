#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table tbl (a int primary key) partition by hash (a) partitions 2" $DBNAME
csql -udba -S -c "create table tbl2 (a int foreign key references tbl(a) on delete cascade) partition by hash (a) partitions 2" $DBNAME
csql -udba -S -c "insert into tbl values (0), (1), (2), (3)" $DBNAME

VFIDS_BEFORE=`cubrid diagdb -d1 $DBNAME | grep -B 13 "tbl" | grep vfid` 

csql -udba -S -i reuse_oid_05.sql $DBNAME

VFIDS_AFTER=`cubrid diagdb -d1 $DBNAME | grep -B 13 "tbl" | grep vfid`

echo " == Expected 1: these two below have to be same == "
echo "Previous VFIDs: $VFIDS_BEFORE" 
echo "Current VFIDs: $VFIDS_AFTER"

echo " == Expected 2: a=0, 1, 2, 3 == "
csql -udba -S -c "select * from tbl" $DBNAME


# Descripttion:
# Check if it is consistent after ROLLBACK. The heap and btree have to be the same as before ROLLBACK# there is no expected result 3 compared to reuse_oid_05.sh because partitioned table can't be inherited

# Expected:
# 2 epxected reults. See comments above

cubrid deletedb $DBNAME
