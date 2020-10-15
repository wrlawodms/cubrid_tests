#!/bin/bash

TBNAME=tbl_test

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

cubrid server start $DBNAME
SERVER_PID=`pgrep -u $USER -f "$DBNAME$"`

csql -udba -c "create table $TBNAME (a char(2000)) encrypt" $DBNAME;

for i in {1..5}
do
  csql -udba -c "insert into $TBNAME (a) values ('$i')" $DBNAME;
done

csql -udba -c "drop table $TBNAME" $DBNAME;

ps aux | grep $SERVER_PID
kill -9 $SERVER_PID
sleep 2

cubrid server start $DBNAME
cubrid server stop $DBNAME

cat $DB_SERVERLOG | grep "TDE:" | egrep -e "pgbuf_dealloc_page|pgbuf_set_tde_algorithm"
# EXPECTED:
# The number of "TDE: pgbuf_dealloc_page()" and "TDE: pgbuf_set_tde_algorithm(): ... tde_algorithm = NONE" 
# must match.
cubrid deletedb $DBNAME
