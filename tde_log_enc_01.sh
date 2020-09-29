#!/bin/bash

TBNAME=tbl_test

rm -rf $DBNAME
mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
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

cat csql.err | egrep -A1 -e "tde_algorithm|logpb_append_next_record";

cubrid deletedb $DBNAME
