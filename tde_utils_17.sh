#!/bin/bash

TBNAME=test_tbl

rm -rf $DBNAME
mkdir $DBNAME
cd $DBNAME

cubrid deletedb $DBNAME

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table $TBNAME (a int) encrypt" $DBNAME
csql -udba -S -c "insert into $TBNAME (a) values(3)" $DBNAME

cubrid backupdb -S -l 0 -k $DBNAME

mv ${DBNAME}_keys ${DBNAME}_tmp_keys
rm ${DBNAME}_bk0_keys # restoredb without the _keys file
cubrid restoredb -k ${DBNAME}_tmp_keys $DBNAME

csql -udba -S -c "select * from $TBNAME" $DBNAME

cubrid deletedb $DBNAME
