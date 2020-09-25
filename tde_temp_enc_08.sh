#!/bin/bash

TBNAME=tbl_test
SRC_TBNAME=tbl_test_src

rm -r $DBNAME
mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME en_US

cubrid server start $DBNAME

csql -udba -c "create table ${TBNAME}(a char(17000)) encrypt;" $DBNAME;
for i in {1..5}
do
  csql -udba -c "insert into ${TBNAME}(a) values (' ');" $DBNAME;
done

cubrid server stop $DBNAME

echo "tde_trace_debug=1" >> $DBCONF
echo "file_logging_debug=1" >> $DBCONF

csql -udba -S -c "create index ${TBNAME}_idx on ${TBNAME} (a);" $DBNAME | grep -A3 "file_apply_tde_algorithm"

cat csql.err | grep -A3 "FILE file_create (SA_MODE): finished creating file."

cubrid deletedb $DBNAME
