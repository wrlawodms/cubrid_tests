#!/bin/bash

TBNAME=test_tbl

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table $TBNAME (a int) encrypt" $DBNAME
csql -udba -S -c "insert into $TBNAME (a) values(3)" $DBNAME

cubrid backupdb -S -o backup.msg $DBNAME
cat backup.msg # EXPECTED: Check if the backup volume includes _keys file
rm $DBNAME
rm ${DBNAME}_keys

cubrid restoredb $DBNAME
# EXPECTED: success

csql -udba -S -c "select * from $TBNAME" $DBNAME
# EXPECTED: can see the value 3

cubrid deletedb $DBNAME
