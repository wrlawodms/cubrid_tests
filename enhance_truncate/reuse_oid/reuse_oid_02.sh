#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid server start $DBNAME

csql -udba -c "create table tbl (a int)" $DBNAME
csql -udba -c "insert into tbl values (3)" $DBNAME

csql -udba -c "truncate tbl" $DBNAME

csql -udba -c "alter table tbl add column b int;" $DBNAME
csql -udba -c "insert into tbl values(0,0)" $DBNAME

echo "---------- Expected 1: (0,0) -----------"
csql -udba -c "select * from tbl" $DBNAME # Expected 1: (0,0);

cubrid server stop $DBNAME

# Descripttion:
# DML and DDL after TRUNCATE

# Expected:
# no error and 1 expected results. See a comment above

cubrid deletedb $DBNAME
