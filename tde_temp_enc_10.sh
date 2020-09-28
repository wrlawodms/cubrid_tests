#!/bin/bash

TBNAME=tbl_test
SRC_TBNAME=tbl_test_src

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME en_US

csql -udba -S -c "create table ${TBNAME}(a char(20000)) encrypt;" $DBNAME;
csql -udba -S -c "insert into ${TBNAME}(a) values (' ');" $DBNAME;
csql -udba -S -c "insert into ${TBNAME}(a) values (' ');" $DBNAME;

echo "tde_trace_debug=1" >> $DBCONF
echo "temp_file_memory_size_in_pages=1" >> $DBCONF

cubrid server start $DBNAME
csql -udba -c "select * from ${TBNAME}" $DBNAME | grep -C1 tde_algorithm;
cubrid server stop $DBNAME

cubrid deletedb $DBNAME
