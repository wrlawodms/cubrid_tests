#!/bin/bash

TBNAME=test_tbl
BKPATH=bk

mkdir $BKPATH

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table $TBNAME (a int) encrypt" $DBNAME
csql -udba -S -c "insert into $TBNAME (a) values(3)" $DBNAME

cubrid backupdb -S -k --destination-path=$BKPATH $DBNAME

ls $BKPATH # EXPECTED: backup volume and the seperated key has to be here
ls  # EXPECTED: not here

cubrid restoredb --backup-file-path=$BKPATH $DBNAME

csql -udba -S -c "select * from $TBNAME" $DBNAME 
# EXPECTED: can see the value 3

cubrid deletedb $DBNAME
