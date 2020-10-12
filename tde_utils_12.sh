#!/bin/bash

TBNAME=test_tbl

rm -rf $DBNAME
mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table $TBNAME (a int) encrypt" $DBNAME
csql -udba -S -c "insert into $TBNAME (a) values(0)" $DBNAME

cubrid backupdb -S -l 0 -o backup.msg $DBNAME
cubrid tde -n $DBNAME
cubrid backupdb -S -l 1 -o backup.msg $DBNAME
cubrid tde -n $DBNAME
cubrid backupdb -S -l 2 -o backup.msg $DBNAME

rm ${DBNAME}_keys
cubrid restoredb -l 0 $DBNAME
cubrid tde -s $DBNAME # check if there is only one key

rm ${DBNAME}_keys
cubrid restoredb -l 1 $DBNAME
cubrid tde -s $DBNAME # check if there are only two keys

rm ${DBNAME}_keys
cubrid restoredb -l 2 $DBNAME
cubrid tde -s $DBNAME # check if there are three keys

csql -udba -S -c "select * from $TBNAME" $DBNAME 

cubrid deletedb $DBNAME
