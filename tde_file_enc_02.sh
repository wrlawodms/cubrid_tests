#!/bin/bash

TBNAME=tbl_test

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

echo "tde_trace_debug=1" >> $DBCONF

cubrid server start $DBNAME

csql -udba -c "create table $TBNAME (a char(2000)) encrypt" $DBNAME;

for i in {1..5}
do
  csql -udba -c "insert into $TBNAME (a) values ('$i')" $DBNAME;
done

cubrid server stop $DBNAME
cubrid deletedb $DBNAME
