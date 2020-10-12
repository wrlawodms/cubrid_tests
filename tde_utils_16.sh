#!/bin/bash

TBNAME=test_tbl
BKPATH=bk

rm -rf $DBNAME
mkdir $DBNAME
cd $DBNAME

mkfifo $BKPATH # create the backup path as a fifo

cubrid deletedb $DBNAME

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table $TBNAME (a int) encrypt" $DBNAME
csql -udba -S -c "insert into $TBNAME (a) values(3)" $DBNAME

cubrid backupdb -S -k --destination-path=$BKPATH $DBNAME # fail

cubrid deletedb $DBNAME
