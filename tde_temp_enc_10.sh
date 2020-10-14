#!/bin/bash

TBNAME=tbl_test
SRC_TBNAME=tbl_test_src

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME en_US

csql -udba -S -c "create table ${TBNAME}(a char(20000)) encrypt;" $DBNAME;
csql -udba -S -c "insert into ${TBNAME}(a) values (' ');" $DBNAME;
csql -udba -S -c "insert into ${TBNAME}(a) values (' ');" $DBNAME;

echo "er_log_debug=1" >> $DBCONF
echo "temp_file_memory_size_in_pages=1" >> $DBCONF

cubrid server start $DBNAME
csql -udba -c "select * from ${TBNAME}" $DBNAME | grep -C1 tde_algorithm;
cubrid server stop $DBNAME

cat $DB_SERVERLOG | grep "TDE:" | egrep -e "file_apply_tde_algorithm|pgbuf_set_tde_algorithm"
# The number of user pages in file_apply_tde_algorithm() when destroying (tde algrorithm = NONE) and that of "pgbuf_set_tde_algorithm()... tde_algorithm=NONE"
# has to match

cubrid deletedb $DBNAME
