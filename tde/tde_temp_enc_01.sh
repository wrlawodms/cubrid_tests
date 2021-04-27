#!/bin/bash

TBNAME=tbl_test
SRC_TBNAME=tbl_test_src

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

csql -udba -S -c "create table $TBNAME (a int);" $DBNAME;
csql -udba -S -c "create table ${TBNAME}_enc (a int) encrypt;" $DBNAME;
csql -udba -S -c "create table ${SRC_TBNAME} (a int);" $DBNAME;
csql -udba -S -c "create table ${SRC_TBNAME}_enc (a int) encrypt;" $DBNAME;

cubrid server start $DBNAME

csql -udba -c "insert into ${TBNAME}(a) values(3)" $DBNAME;

csql -udba -c "insert into ${TBNAME}_enc (a) values(3)" $DBNAME;
csql -udba -c "insert into ${TBNAME}(a) select * from ${SRC_TBNAME}_enc" $DBNAME;
csql -udba -c "insert into ${TBNAME}_enc(a) select * from ${SRC_TBNAME}" $DBNAME;

cubrid server stop $DBNAME

cat $DB_SERVERLOG | grep "TDE:" | egrep -e "includes_tde_class "
# EXPECTED:
# TDE: qmgr_execute_query(): includes_tde_class = 0, 1, 1, 1

cubrid deletedb $DBNAME
