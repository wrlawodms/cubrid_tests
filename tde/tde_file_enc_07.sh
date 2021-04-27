#!/bin/bash

TBNAME=tbl_test

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

csql -udba -S -c "create table $TBNAME (a char(2000)) encrypt" $DBNAME;

echo "log_trace_debug=1" >> $DBCONF

cubrid server start $DBNAME
SERVER_PID=`pgrep -u $USER -f "$DBNAME$"`

for i in {1..2}
do
  csql -udba -c "insert into $TBNAME (a) values ('$i')" $DBNAME;
done

ps aux | grep $SERVER_PID
kill -9 $SERVER_PID
sleep 2

cubrid server start $DBNAME # must say REDOING: RVPGBUF_SET_TDE_ALGORITHM
cubrid server stop $DBNAME

cat $DB_SERVERLOG | grep "TDE:" | egrep -e "pgbuf_set_tde_algorithm"
# EXPECTED:
# must say "TDE: pgbuf_set_tde_algorithm():.. AES" twice
# , one of which is generated while normal processing, and the other is generated while recovery processing.

cubrid deletedb $DBNAME
