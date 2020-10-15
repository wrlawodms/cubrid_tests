#!/bin/bash

TBNAME=tbl_test

cubrid createdb --db-volume-size=128M --log-volume-size=20M $DBNAME en_US.utf8

echo "log_compress=0" >> $DBCONF

cubrid server start $DBNAME
SERVER_PID=`pgrep -u $USER -f "$DBNAME$"`

csql -udba -c "create table ${TBNAME} (a char(1048576), b int) encrypt" $DBNAME; # 1M

# inserting until generating archive log
for i in {1..5}
do
  csql -udba -c "insert into $TBNAME (a, b) values(' ', $i)" $DBNAME;
done

ps aux | grep $SERVER_PID
kill -9 $SERVER_PID
sleep 2

echo "logpb_logging_debug=1" >> $DBCONF

# restart for recovery and check
csql -S -udba -c "select b from $TBNAME where b=1;" $DBNAME
# EXPECTED: success to restart

# make sure to use archive log page
cat csql.err | egrep -e "logpb_fetch_from_archive" | wc -l 
# EXPECTED: any number larger than 0
# , which means restart process involves reading archive log.

cubrid deletedb $DBNAME
