#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table tbl (a int primary key) dont_reuse_oid" $DBNAME
csql -udba -S -c "insert into tbl values(3)" $DBNAME

cubrid server start $DBNAME
csql -udba -c "truncate tbl" $DBNAME
cubrid server stop $DBNAME

echo "vacuum_disable=1" >> $DBCONF

echo "========== EXPECTED 1: Distinct Key Count: 0 ========="
cubrid diagdb -d4 $DBNAME | grep -A3 "tbl" # expected 1: 0

# Descripttion:
# Indexes could be recreated while TRUNCATE. This indexes have to have no records even if heap records were mvcc records.

# Expected:
# 2 expected results. See each comments above

cubrid deletedb $DBNAME
