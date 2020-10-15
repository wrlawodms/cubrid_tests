#!/bin/bash

TBNAME=test_tbl

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table $TBNAME (a int) encrypt" $DBNAME
csql -udba -S -c "insert into $TBNAME (a) values(3)" $DBNAME

cubrid backupdb -S -k -o backup.msg $DBNAME
ls # EXPECTED: Check if there is sepreated_keys file (_bk0_keys)
cat backup.msg # EXPECTED: Check if the backup volume includes _keys file (has not to include no _keys file)
rm $DBNAME
rm ${DBNAME}_keys

cubrid restoredb $DBNAME

csql -udba -S -c "select * from $TBNAME" $DBNAME
# EXPECTED: can see value 3

cubrid deletedb $DBNAME
