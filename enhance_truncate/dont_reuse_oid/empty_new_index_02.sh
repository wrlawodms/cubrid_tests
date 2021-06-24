#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table tbl (a int primary key, b int) dont_reuse_oid" $DBNAME
csql -udba -S -c "insert into tbl values(3, 3)" $DBNAME

cubrid server start $DBNAME
csql -udba -c "truncate tbl" $DBNAME
csql -udba -c "insert into tbl values(3, 3)" $DBNAME
csql -udba -c "create index idx_tbl on tbl(b)" $DBNAME
cubrid server stop $DBNAME

echo "========== EXPECTED 1: Distinct Key Count: 1 ==="
cubrid diagdb -d4 $DBNAME | grep -A3 "idx_tbl" # expected 1: 1

# Description
# We have to make sure an index can load from heap records after truncate

# Expected:
# See each comments above

cubrid deletedb $DBNAME
