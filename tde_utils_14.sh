#!/bin/bash

TBNAME=test_tbl

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table $TBNAME (a int) encrypt" $DBNAME
csql -udba -S -c "insert into $TBNAME (a) values(3)" $DBNAME

echo "backup_volume_max_size_bytes=104857600" >> $DBCONF #100M

cubrid backupdb -S -k -l 0 -o backup.msg $DBNAME
cubrid backupdb -S -k -l 1 -o backup.msg $DBNAME
cubrid backupdb -S -k -l 2 -o backup.msg $DBNAME
ls # EXPECTED: Check if there is only one seperated_keys file (_bk0_keys) per each level regardless of how many backup file has been generated. _bk0_keys, _bk1_keys, _bk2_keys

cubrid restoredb $DBNAME

csql -udba -S -c "select * from $TBNAME" $DBNAME
# EXPECTED: can see value 3

cubrid deletedb $DBNAME
