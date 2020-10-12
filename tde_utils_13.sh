#!/bin/bash

TBNAME=test_tbl

rm -rf $DBNAME
mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table $TBNAME (a int) encrypt" $DBNAME
csql -udba -S -c "insert into $TBNAME (a) values(3)" $DBNAME

cubrid backupdb -S -k -o backup.msg $DBNAME
ls # Check if there is sepreated_keys file (_bk0_keys)
cat backup.msg # Check if the backup volume includes _keys file (has to be no _keys file)
rm $DBNAME
rm ${DBNAME}_keys

cubrid restoredb $DBNAME

csql -udba -S -c "select * from $TBNAME" $DBNAME 

cubrid deletedb $DBNAME
