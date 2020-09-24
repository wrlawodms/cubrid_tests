#!/bin/bash

TBNAME=tbl_test

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

csql -udba -S -c "create table $TBNAME (a int) encrypt;" $DBNAME;

cubrid server start $DBNAME
SERVER_PID=`pgrep -u $USER -f "$DBNAME$"`

csql -udba -c "drop table $TBNAME" --no-auto-commit $DBNAME; # UNDO dellac pages in file_destroy()

ps aux | grep $SERVER_PID
kill -9 $SERVER_PID
sleep 2

echo "tde_trace_debug=1" >> $DBCONF
echo "log_trace_debug=1" >> $DBCONF

cubrid server start $DBNAME
cubrid server stop $DBNAME

cubrid deletedb $DBNAME
