#!/bin/bash

TBNAME=tbl_test
SRC_TBNAME=tbl_test_src

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8
cubrid server start $DBNAME

csql -udba -c "create table $TBNAME (a int, b int);" $DBNAME;
csql -udba -c "create table ${TBNAME}_enc (a int, b int) encrypt;" $DBNAME;
csql -udba -c "create table ${SRC_TBNAME} (a int, b int);" $DBNAME;
csql -udba -c "create table ${SRC_TBNAME}_enc (a int, b int) encrypt;" $DBNAME;

cubrid server stop $DBNAME

cubrid server start $DBNAME

csql -udba -c "merge into ${TBNAME} using ${SRC_TBNAME} on ${TBNAME}.a=${SRC_TBNAME}.a when not matched then insert values (${SRC_TBNAME}.a, ${SRC_TBNAME}.b);" $DBNAME;
csql -udba -c "merge into ${TBNAME} using ${SRC_TBNAME} on ${TBNAME}.a=${SRC_TBNAME}.a when matched then update set ${TBNAME}.b=${SRC_TBNAME}.b;" $DBNAME;
csql -udba -c "merge into ${TBNAME} using ${SRC_TBNAME} on ${TBNAME}.a=${SRC_TBNAME}.a when matched then update set ${TBNAME}.b=${SRC_TBNAME}.b when not matched then insert values (${SRC_TBNAME}.a, ${SRC_TBNAME}.b);" $DBNAME;

csql -udba -c "merge into ${TBNAME}_enc using ${SRC_TBNAME} on ${TBNAME}_enc.a=${SRC_TBNAME}.a when not matched then insert values (${SRC_TBNAME}.a, ${SRC_TBNAME}.b);" $DBNAME;
csql -udba -c "merge into ${TBNAME}_enc using ${SRC_TBNAME} on ${TBNAME}_enc.a=${SRC_TBNAME}.a when matched then update set ${TBNAME}_enc.b=${SRC_TBNAME}.b;" $DBNAME;
csql -udba -c "merge into ${TBNAME}_enc using ${SRC_TBNAME} on ${TBNAME}_enc.a=${SRC_TBNAME}.a when matched then update set ${TBNAME}_enc.b=${SRC_TBNAME}.b when not matched then insert values (${SRC_TBNAME}.a, ${SRC_TBNAME}.b);" $DBNAME;

csql -udba -c "merge into ${TBNAME} using ${SRC_TBNAME}_enc on ${TBNAME}.a=${SRC_TBNAME}_enc.a when not matched then insert values (${SRC_TBNAME}_enc.a, ${SRC_TBNAME}_enc.b);" $DBNAME;
csql -udba -c "merge into ${TBNAME} using ${SRC_TBNAME}_enc on ${TBNAME}.a=${SRC_TBNAME}_enc.a when matched then update set ${TBNAME}.b=${SRC_TBNAME}_enc.b;" $DBNAME;
csql -udba -c "merge into ${TBNAME} using ${SRC_TBNAME}_enc on ${TBNAME}.a=${SRC_TBNAME}_enc.a when matched then update set ${TBNAME}.b=${SRC_TBNAME}_enc.b when not matched then insert values (${SRC_TBNAME}_enc.a, ${SRC_TBNAME}_enc.b);" $DBNAME;

csql -udba -c "merge into ${TBNAME}_enc using ${SRC_TBNAME}_enc on ${TBNAME}_enc.a=${SRC_TBNAME}_enc.a when not matched then insert values (${SRC_TBNAME}_enc.a, ${SRC_TBNAME}_enc.b);" $DBNAME;
csql -udba -c "merge into ${TBNAME}_enc using ${SRC_TBNAME}_enc on ${TBNAME}_enc.a=${SRC_TBNAME}_enc.a when matched then update set ${TBNAME}_enc.b=${SRC_TBNAME}_enc.b;" $DBNAME;
csql -udba -c "merge into ${TBNAME}_enc using ${SRC_TBNAME}_enc on ${TBNAME}_enc.a=${SRC_TBNAME}_enc.a when matched then update set ${TBNAME}_enc.b=${SRC_TBNAME}_enc.b when not matched then insert values (${SRC_TBNAME}_enc.a, ${SRC_TBNAME}_enc.b);" $DBNAME;

cubrid server stop $DBNAME

cat $DB_SERVERLOG | grep "TDE:" | egrep -e "includes_tde_class "
# EXPECTED:
# TDE: qmgr_execute_query(): includes_tde_class = 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1
# three 0, nine 1

cubrid deletedb $DBNAME
