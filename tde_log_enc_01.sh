#!/bin/bash

TBNAME=tbl_test

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME en_US

csql -udba -S -c "create table ${TBNAME}(a char(9000));" $DBNAME;
csql -udba -S -c "create table ${TBNAME}_enc(a char(9000)) encrypt;" $DBNAME;
csql -udba -S -c "create table ${TBNAME}_big_enc(a char(40000)) encrypt;" $DBNAME;

echo "logpb_logging_debug=1" >> $DBCONF
echo "log_compress=0" >> $DBCONF

for i in {1..3}
do
csql -udba -S -c "insert into ${TBNAME}_enc (a) values(' ')" $DBNAME
done

csql -udba -S -c "insert into ${TBNAME}_big_enc (a) values(' ')" $DBNAME

cat csql.err | egrep -e "logpb_start_append|logpb_next_append_page";
# EXPECTED:
# The three kinds of logs should be shown:
# logpb_start_append: set tde_algorithm to existing page (..), tde_algorithm = AES 
# logpb_start_append: tde_algorithm already set to existing page (..), tde_algorithm = AES
# logpb_next_append_page: set tde_algorithm to appending page (..), tde_algorithm = AES 
# All log pages has to be encryted

cubrid deletedb $DBNAME
