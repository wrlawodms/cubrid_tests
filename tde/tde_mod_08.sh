#!/bin/bash

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

echo "log_compress=0" >> $DBCONF

cubrid server start ${DBNAME}
SERVER_PID=`pgrep -u $USER -f "$DBNAME$"`
csql -udba -c "create table a (a int) encrypt" ${DBNAME}
csql -udba -c "create table sp (sp char(20000))" ${DBNAME}
csql -udba -c "insert into a (a) values(3)" ${DBNAME}
csql -udba -c "insert into sp (sp) values(' ')" ${DBNAME}

ps aux | grep $SERVER_PID
kill -9 $SERVER_PID
sleep 2
ps aux | grep $SERVER_PID
# cubrid server stop ${DBNAME}

rm ${DBNAME}_keys

cubrid server start ${DBNAME}
# EXPECTED: failt to restart (fatala error)

cubrid deletedb $DBNAME
