#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table tbl (a int primary key)" $DBNAME
csql -udba -S -c "insert into tbl values (0)" $DBNAME

VFIDS_BEFORE=`cubrid diagdb -d1 $DBNAME | grep -B 13 "tbl" | grep vfid` 

csql -udba -S -i reuse_oid_05.sql $DBNAME

VFIDS_AFTER=`cubrid diagdb -d1 $DBNAME | grep -B 13 "tbl" | grep vfid`

# Expected 1: these two below have to be same"
echo "Previous VFIDs: $VFIDS_BEFORE" 
echo "Current VFIDs: $VFIDS_AFTER"

csql -udba -S -c "select * from tbl" $DBNAME # Expected 2: onlt one record : a=0

csql -udba -S -c "create table tbl2 under tbl" $DBNAME # In this case, index is not dropped.
csql -udba -S -i reuse_oid_05.sql $DBNAME
csql -udba -S -c "select * from tbl" $DBNAME # Expected 3: onlt one record : a=0

# Descripttion:
# Check if it is consistent after ROLLBACK. The heap and btree have to be the same as before ROLLBACK 

# Expected:
# 3 epxected reults. See comments above

cubrid deletedb $DBNAME
