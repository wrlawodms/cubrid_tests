#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table tbl (a int)" $DBNAME
cubrid diagdb -d1 $DBNAME > ${DBNAME}_diag_d1_1
echo "-------Expected 1: count(*): 0 -------"
csql -udba -S -c "select count(*) from tbl" $DBNAME  # Expected 1: 0 
csql -udba -S -c "truncate tbl" $DBNAME
cubrid diagdb -d1 $DBNAME > ${DBNAME}_diag_d1_2

VFID_BEFORE=`cat ${DBNAME}_diag_d1_1 | grep -B 13 "tbl" | grep vfid`
VFID_AFTER=`cat ${DBNAME}_diag_d1_2 | grep -B 13 "tbl" | grep vfid`

echo "-------Expected 2: different VFID -------"
echo "Before: $VFID_BEFORE, After: $VFID_AFTER" # Expected 2: different"

echo "-------Expected 3: can't find the previous VFID -------"
cat ${DBNAME}_diag_d1_2 | grep "$VFID_BEFORE"  # can't find

rm ${DBNAME}_diag_d1_*

# Descripttion:
# TRUNCATE on a table with REUSE_OID make it have a new heap file.

# Expected:
# 2 expected results. See each comments above

cubrid deletedb $DBNAME
