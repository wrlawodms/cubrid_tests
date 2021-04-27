#!/bin/bash

TBNAME=tbl_test

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

csql -udba -S -c "create table $TBNAME (a char(2000)) encrypt" $DBNAME;

echo "log_trace_debug=1" >> $DBCONF

cubrid server start $DBNAME
SERVER_PID=`pgrep -u $USER -f "$DBNAME$"`

csql -udba -c "insert into $TBNAME (a) values (' '); insert into $TBNAME (a) values (' ');" --no-auto-commit $DBNAME;

ps aux | grep $SERVER_PID
kill -9 $SERVER_PID
sleep 2

cubrid server start $DBNAME

cubrid server stop $DBNAME
cubrid deletedb $DBNAME
