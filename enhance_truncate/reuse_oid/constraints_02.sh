#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid server start $DBNAME

csql -udba -c "create table tbl1 (a int primary key)" $DBNAME
csql -udba -c "create table tbl2 (a int foreign key references tbl1(a) on delete cascade)" $DBNAME

csql -udba -c "insert into tbl1 values(3)" $DBNAME
csql -udba -c "insert into tbl2 values(3)" $DBNAME
echo "-------Expected 1: all count(*): 1 -------"
csql -udba -c "select count(*) from tbl1" $DBNAME
csql -udba -c "select count(*) from tbl2" $DBNAME

cubrid server stop $DBNAME
cubrid diagdb -d1 $DBNAME > ${DBNAME}_diag_d1_1
cubrid server start $DBNAME

csql -udba -c "truncate tbl1 cascade" $DBNAME

echo "-------Expected 2: All count(*): 0 -------"
csql -udba -c "select count(*) from tbl1" $DBNAME
csql -udba -c "select count(*) from tbl2" $DBNAME

cubrid server stop $DBNAME
cubrid diagdb -d1 $DBNAME > ${DBNAME}_diag_d1_2

VFID_BEFORE=`cat ${DBNAME}_diag_d1_1 | grep -B 13 "tbl" | grep vfid`
VFID_AFTER=`cat ${DBNAME}_diag_d1_2 | grep -B 13 "tbl" | grep vfid`

echo "-------Expected 3: different VFID -------"
echo "Before:"
echo "$VFID_BEFORE"
echo "After:"
echo "$VFID_AFTER" # Expected 3: different"

# rm ${DBNAME}_diag_d1_*

# Descripttion:
# TRUNCATE a table which has the PK referred by a FK. To see if the index file is recreated.

# Expected:
# 3 expected results. 

cubrid deletedb $DBNAME
