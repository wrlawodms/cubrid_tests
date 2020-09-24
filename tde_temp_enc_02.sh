#!/bin/bash

TBNAME=tbl_test
SRC_TBNAME=tbl_test_src

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

csql -udba -S -c "create table $TBNAME (a int);" $DBNAME;
csql -udba -S -c "create table ${TBNAME}_enc (a int) encrypt;" $DBNAME;

csql -udba -S -c "insert into ${TBNAME} (a) values(3)" $DBNAME;
csql -udba -S -c "insert into ${TBNAME}_enc (a) values(3)" $DBNAME;

echo "tde_trace_debug=1" >> $DBCONF

cubrid server start $DBNAME

csql -udba -c "update ${TBNAME} set a = 4" $DBNAME;
csql -udba -c "update ${TBNAME}_enc set a = 4" $DBNAME;

cubrid server stop $DBNAME

cubrid deletedb $DBNAME
