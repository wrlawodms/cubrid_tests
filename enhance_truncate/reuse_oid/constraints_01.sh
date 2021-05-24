#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid server start $DBNAME

csql -udba -c "create table tbl_hash (a int primary key) partition by hash (a) partitions 2" $DBNAME
csql -udba -c "create table tbl_range (a int primary key) partition by range (a) \
  (partition lt_10 values less than (10), partition lt_100 values less than (100))" $DBNAME
csql -udba -c "create table tbl_list (a int primary key) partition by list (a) \
  (partition ten values in (10), partition hun values in (100))" $DBNAME

csql -udba -i constraints_01_insert.sql $DBNAME
echo "-------Expected 1: All count(*): 2 -------"
csql -udba -i constraints_01_select.sql $DBNAME

cubrid server stop $DBNAME
cubrid diagdb -d1 $DBNAME > ${DBNAME}_diag_d1_1
cubrid server start $DBNAME

csql -udba -i constraints_01_truncate.sql $DBNAME # has to be with ;auto commit off
echo "-------Expected 2: All count(*): 0 -------"
csql -udba -i constraints_01_select.sql $DBNAME

cubrid server stop $DBNAME
cubrid diagdb -d1 $DBNAME > ${DBNAME}_diag_d1_2

VFID_BEFORE=`cat ${DBNAME}_diag_d1_1 | grep -B 13 "tbl" | grep vfid`
VFID_AFTER=`cat ${DBNAME}_diag_d1_2 | grep -B 13 "tbl" | grep vfid`

echo "-------Expected 3: different VFID -------"
echo "Before:"
echo "$VFID_BEFORE"
echo "After:"
echo "$VFID_AFTER" # Expected 3: different"

rm ${DBNAME}_diag_d1_*

# Descripttion:
# TRUNCATE on a partition table recreates all the index files

# Expected:
# 3 expected results. See each comments above

cubrid deletedb $DBNAME
