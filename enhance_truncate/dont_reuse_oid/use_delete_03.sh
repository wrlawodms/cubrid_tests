#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table tbl (a int) dont_reuse_oid" $DBNAME

csql -udba -S -c "insert into tbl values(3)" $DBNAME
echo "-------Expected 1: count(*): 1 -------"
csql -udba -S -c "select count(*) from tbl" $DBNAME # Expected 1: 1

cubrid diagdb -d1 $DBNAME > ${DBNAME}_diag_d1_1

csql -udba -S -c "create table objset (a set(object))" $DBNAME

csql -udba -S -c "truncate tbl" $DBNAME
echo "-------Expected 2: count(*): 0 -------"
csql -udba -S -c "select count(*) from tbl" $DBNAME  # Expected 2: 0 

cubrid diagdb -d1 $DBNAME > ${DBNAME}_diag_d1_2

VFID_BEFORE=`cat ${DBNAME}_diag_d1_1 | grep -B 13 "tbl" | grep vfid`
VFID_AFTER=`cat ${DBNAME}_diag_d1_2 | grep -B 13 "tbl" | grep vfid`

echo "-------Expected 3: same VFID -------"
echo "Before: $VFID_BEFORE, After: $VFID_AFTER" # Expected 3: different"

rm ${DBNAME}_diag_d1_*

# Descripttion:
# Basically, TRUNCATE on a table with DONT_REUSE_OID make it have a new heap file.
# However, there some cases in which we can't destory, so use DELETE.
# 1) There is a general object domain type
# 2) There is a sequence, set, multiset of general object domain type
# 3) there is a object domain type using the class to truncate.
# 4) there is a sequence, set, multiset of domain type using the class to truncate.
# This is the case (2)-2

# Expected:
# See each comments above

cubrid deletedb $DBNAME
