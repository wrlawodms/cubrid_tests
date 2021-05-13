#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid server start $DBNAME

csql -udba -c "create table tbl (a int primary key)" $DBNAME
csql -udba -i reuse_oid_04.sql $DBNAME

cubrid server stop $DBNAME

# expected1: all 0 Key count except for pk_tbl3_a which has one key.

# Descripttion:
# statistics for the truncated class has to be initialized properly.

# Expected:
# Total obejcts = 1 from the last ";info stats", see the reuse_oid_04.sql

cubrid deletedb $DBNAME
