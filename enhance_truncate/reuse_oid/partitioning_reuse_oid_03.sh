#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid server start $DBNAME

# Case 1: a droppable PK 
csql -udba -c "create table tbl1 (a int primary key) partition by hash (a) partitions 2" $DBNAME
csql -udba -c "insert into tbl1 values (1), (2), (3), (4)" $DBNAME
csql -udba -c "truncate tbl1" $DBNAME

# Case 2: a droppable PK referred to by a FK. 
csql -udba -c "create table tbl2 (a int primary key) partition by hash (a) partitions 2" $DBNAME
csql -udba -c "create table tbl2_FK (a int foreign key references tbl2(a) on delete cascade, b int primary key)" $DBNAME
csql -udba -c "insert into tbl2 values (1), (2), (3), (4)" $DBNAME
csql -udba -c "insert into tbl2_FK values (1,1), (2,2), (3,3), (4,4)" $DBNAME
csql -udba -c "truncate tbl2 cascade" $DBNAME

# partitioning table is always droppable

cubrid server stop $DBNAME

echo "---------- Expected 1: all 0 Key count -----------"
cubrid diagdb -d4 $DBNAME | grep -A3 -e "tbl" 
# expected1: all 0 Key count

# Descripttion:
# All index records are removed after TRUNCATE even if a index can't be dropped
# Different from reuse_oid_03.sh, partitiong table can't be inherited, so there is no case 3

# Expected:
# no error and 1 expected results. See a comment above

cubrid deletedb $DBNAME
