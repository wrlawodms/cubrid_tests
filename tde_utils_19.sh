#!/bin/bash

TBNAME=test_tbl

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table $TBNAME (a int) encrypt" $DBNAME
csql -udba -S -c "insert into $TBNAME (a) values(3)" $DBNAME

mkdir keys
mv ${DBNAME}_keys keys

echo "tde_keys_file_path=keys" >> $DBCONF

cubrid backupdb -S -k $DBNAME

ls # EXPECTED: _bk0_keys file has to be created in the dir the backup volume belongs
ls keys # EXPECTED: not here

cubrid restoredb $DBNAME

csql -udba -S -c "select * from $TBNAME" $DBNAME 
# EXPECTED: you can see the value 3

cubrid deletedb $DBNAME
