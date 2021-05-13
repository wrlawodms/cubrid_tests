#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid server start $DBNAME

# Case 1: a droppable PK 
csql -udba -c "create table tbl1 (a int primary key)" $DBNAME
csql -udba -c "insert into tbl1 values (3)" $DBNAME
csql -udba -c "truncate tbl1" $DBNAME

# Case 2: an undoppable PK referred to by a FK. 
csql -udba -c "create table tbl2 (a int primary key)" $DBNAME
csql -udba -c "create table tbl2_FK (a int foreign key references tbl2(a) on delete cascade, b int primary key)" $DBNAME
csql -udba -c "insert into tbl2 values (3)" $DBNAME
csql -udba -c "insert into tbl2_FK values (3,4)" $DBNAME
csql -udba -c "truncate tbl2 cascade" $DBNAME

# Case 3: an undroppable PK shared with a child class in an inheritance hierachy.
csql -udba -c "create table tbl3 (a int primary key)" $DBNAME
csql -udba -c "create table tbl3_child under tbl3" $DBNAME
csql -udba -c "insert into tbl3 values(2)" $DBNAME
csql -udba -c "insert into tbl3 values(3)" $DBNAME
csql -udba -c "insert into tbl3_child values(4)" $DBNAME
csql -udba -c "truncate tbl3" $DBNAME

cubrid server stop $DBNAME

echo "---------- Expected 1: all 0 Key count except for pk_tbl3_a -----------"
cubrid diagdb -d4 $DBNAME | grep -A3 -e "tbl" 
# expected1: all 0 Key count except for pk_tbl3_a which has one key.

# Descripttion:
# All index records are removed after TRUNCATE even if a index can't be dropped

# Expected:
# no error and 1 expected results. See a comment above

cubrid deletedb $DBNAME
