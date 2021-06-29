#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid server start $DBNAME

csql -udba -c "create table tbl (a int primary key)" $DBNAME
csql -udba -i reuse_oid_04.sql $DBNAME

echo ""
echo "** Expected: Total obejcts = 1 from the last ';info stats' and not the epoch timestamp"
echo ""

cubrid server stop $DBNAME

# Descripttion:
# statistics for the truncated class has to be initialized properly.

# Expected:
# Total obejcts = 1 from the last ";info stats", see the reuse_oid_04.sql

cubrid deletedb $DBNAME
