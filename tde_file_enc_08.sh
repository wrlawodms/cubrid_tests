#!/bin/bash

TBNAME=tbl_test

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

echo "log_trace_debug=1" >> $DBCONF

cubrid server start $DBNAME
SERVER_PID=`pgrep -u $USER -f "$DBNAME$"`

csql -udba -c "create table $TBNAME (a char(2000)) encrypt;" --no-auto-commit $DBNAME; # reply 'N' to the prompt

ps aux | grep $SERVER_PID
kill -9 $SERVER_PID
sleep 2

cubrid server start $DBNAME
# EXPECTED:
# Must say REDOING: RVFL_FHEAD_SET_TDE_ALGORITHM, UNDOING: RVFL_FHEAD_SET_TDE_ALGORITHM
# Must say REDOING: RVPGBUF_SET_TDE_ALGORITHM, UNDOING: RVPGBUF_SET_TDE_ALGORITHM
cubrid server stop $DBNAME

cat $DB_SERVERLOG | egrep "TDE: file_set_tde_algorithm_internal|pgbuf_set_tde_algorithm" 
# EXPECTED: 
# Must say like below: (VFID doesn't matter): 
# file_set_tde_algorithm_internal(): VFID = 0|3520, tde_algorithm = AES 
# TDE: pgbuf_set_tde_algorithm(): VPID = 0|3521, tde_algorithm = AES
# TDE: pgbuf_set_tde_algorithm(): VPID = 0|3521, tde_algorithm = NONE
# file_set_tde_algorithm_internal(): VFID = 0|3520, tde_algorithm = NONE 
# file_set_tde_algorithm_internal(): VFID = 0|3520, tde_algorithm = AES 
# TDE: pgbuf_set_tde_algorithm(): VPID = 0|3521, tde_algorithm = AES
# TDE: pgbuf_set_tde_algorithm(): VPID = 0|3521, tde_algorithm = NONE
# file_set_tde_algorithm_internal(): VFID = 0|3520, tde_algorithm = NONE

cubrid deletedb $DBNAME
