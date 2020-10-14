#!/bin/bash

TBNAME=tbl_test

rm -rf $DBNAME
mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

csql -udba -S -c "create table ${TBNAME}_enc (a char(10000)) encrypt" $DBNAME;

echo "logpb_logging_debug=1" >> $DBCONF
echo "background_archiving=1" >> $DBCONF
echo "log_compress=0" >> $DBCONF

csql -udba -S -c "insert into ${TBNAME}_enc (a) values ('TDE_TEST_ENCRYPT');" $DBNAME;

cat csql.err | egrep -e "logpb_start_append|logpb_next_append_page"
cat csql.err | egrep -e "logpb_writev_append_pages|logpb_write_page_to_disk" 
# the logical page id of pages marked as encrypted and thet of the pages encrypted 
# must match

cubrid deletedb $DBNAME
