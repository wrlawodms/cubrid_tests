#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table tbl (a int)" $DBNAME

csql -udba -S -c "insert into tbl values(3)" $DBNAME
echo "-------Expected 1: count(*): 1 -------"
csql -udba -S -c "select count(*) from tbl" $DBNAME # Expected 1: 1

cubrid diagdb -d1 $DBNAME > ${DBNAME}_diag_d1_1

csql -udba -S -c "truncate tbl" $DBNAME
echo "-------Expected 2: count(*): 0 -------"
csql -udba -S -c "select count(*) from tbl" $DBNAME  # Expected 2: 0 

cubrid diagdb -d1 $DBNAME > ${DBNAME}_diag_d1_2

VFID_BEFORE=`cat ${DBNAME}_diag_d1_1 | grep -B 13 "tbl" | grep vfid`
VFID_AFTER=`cat ${DBNAME}_diag_d1_2 | grep -B 13 "tbl" | grep vfid`

echo "-------Expected 3: different VFID -------"
echo "Before: $VFID_BEFORE, After: $VFID_AFTER" # Expected 3: different"

echo "-------Expected 4: can't find the previous VFID -------"
cat ${DBNAME}_diag_d1_2 | grep "$VFID_BEFORE"  # Expected 4: can't find

rm ${DBNAME}_diag_d1_*

# Descripttion:
# TRUNCATE on a table with REUSE_OID make it have a new heap file.

# Expected:
# 2 expected results. See each comments above

cubrid deletedb $DBNAME
