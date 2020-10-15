#!/bin/bash

TBNAME=tbl_test

rm -rf $DBNAME
mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME en_US

echo "er_log_debug=1" >> $DBCONF

cubrid server start $DBNAME
# NOTE: Assuming that HA nodes are up, and queries below are executed on master node
csql -udba -c "create table ${TBNAME} (a int primary key, b int) encrypt;" $DBNAME

csql -udba -c "insert into ${TBNAME} (a, b) values (1,2);" $DBNAME # RVREPL_DATA_INSERT
csql -udba -c "insert into ${TBNAME} (a, b) values (2,1);" $DBNAME

csql -udba -c "update ${TBNAME} set b=2 where b=1;" $DBNAME # RVREPL_DATA_UPDATE

csql -udba -c "update ${TBNAME} set b=3 where b=2;" $DBNAME # RVREPL_DATA_UPDATE_START, RVREPL_DATA_UPDATE_END
csql -udba -c "delete ${TBNAME} where a=1;" $DBNAME # RVREPL_DATA_DELETE

cubrid server stop $DBNAME

cat $DB_SERVERLOG | grep "prior_set_tde_encrypted";
# EXPECTED
# must be able to see RVREPL_DATA_INSERT, RVREPL_DATA_UPDATE, RVREPL_DATA_UPDATE_START, RVREPL_DATA_UPDATE_END, RVREPL_DATA_DELETE" in prior_set_tde_encrypted(): rcvindex = XXX ;

cubrid deletedb $DBNAME
