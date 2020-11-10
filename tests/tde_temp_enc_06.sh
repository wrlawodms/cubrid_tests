#!/bin/bash

TBNAME=tbl_test
SRC_TBNAME=tbl_test_src

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

csql -udba -S -c "create table ${TBNAME}_enc (a int) encrypt;" $DBNAME;

cubrid server start $DBNAME
csql -udba -c "select * from ${TBNAME}_enc" $DBNAME;
cubrid server stop $DBNAME

echo "max_plan_cache_entries=0" >> $DBCONF

cubrid server start $DBNAME
csql -udba -c "select * from ${TBNAME}_enc" $DBNAME;
cubrid server stop $DBNAME

cat $DB_SERVERLOG | grep "TDE:" | egrep -e "includes_tde_class "
# EXPECTED:
# TDE: qmgr_process_query(): includes_tde_class = 1, 1

cubrid deletedb $DBNAME
