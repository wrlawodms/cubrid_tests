#!/bin/bash

TBNAME=tbl_test

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

echo "tde_trace_debug=1" >> $DBCONF

cubrid server start $DBNAME

csql -udba -c "create table $TBNAME (a char(20000)) reuse_oid encrypt" $DBNAME;
csql -udba -c "insert into $TBNAME (a) values (' ')" $DBNAME;
csql -udba -c "drop table $TBNAME" $DBNAME

cubrid server stop $DBNAME
cubrid deletedb $DBNAME
