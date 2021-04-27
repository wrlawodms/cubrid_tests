#!/bin/bash

TBNAME=tbl_test
SRC_TBNAME=tbl_test_src

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME en_US

csql -udba -S -c "create table ${TBNAME}_aes(a char(20000)) encrypt;" $DBNAME;
csql -udba -S -c "insert into ${TBNAME}_aes(a) values (' ');" $DBNAME;
csql -udba -S -c "insert into ${TBNAME}_aes(a) values (' ');" $DBNAME;
csql -udba -S -c "create table ${TBNAME}(a char(20000));" $DBNAME;
csql -udba -S -c "insert into ${TBNAME}(a) values (' ');" $DBNAME;
csql -udba -S -c "insert into ${TBNAME}(a) values (' ');" $DBNAME;

echo "temp_file_memory_size_in_pages=1" >> $DBCONF

cubrid server start $DBNAME
csql -udba -o /dev/null -c "select * from ${TBNAME}_aes" $DBNAME
csql -udba -o /dev/null -c "select * from ${TBNAME}" $DBNAME
cubrid server stop $DBNAME

cat $DB_SERVERLOG | grep "TDE:" | egrep -e "file_alloc"
# EXPECTED:
# 3 * file_alloc() : tde_algorithm of file: AES, previous tde algorithm of page = NONE
# 3 * file_alloc() : tde_algorithm of file: NONE, previous tde algorithm of page = AES
 
cubrid deletedb $DBNAME
