#!/bin/bash

TBNAME=tbl_test
SRC_TBNAME=tbl_test_src

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

csql -udba -S -c "create table ${TBNAME}_enc (a int) encrypt;" $DBNAME;

echo "er_log_debug=1" >> $DBCONF
cubrid server start $DBNAME
csql -udba -c "select * from ${TBNAME}_enc" $DBNAME;
cubrid server stop $DBNAME

echo "max_plan_cache_entries=0" >> $DBCONF

cubrid server start $DBNAME
csql -udba -c "select * from ${TBNAME}_enc" $DBNAME;
cubrid server stop $DBNAME

cat $DB_SERVERLOG | grep "TDE:" | egrep -e "includes_tde_algorithm "

cubrid deletedb $DBNAME
