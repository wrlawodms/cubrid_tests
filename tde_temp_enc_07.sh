#!/bin/bash

TBNAME=tbl_test
SRC_TBNAME=tbl_test_src

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME en_US

csql -udba -S -c "create table ${TBNAME}(a char(20000)) encrypt;" $DBNAME;
csql -udba -S -c "insert into ${TBNAME}(a) values (' ');" $DBNAME;

echo "temp_file_memory_size_in_pages=1" >> $DBCONF

cubrid server start $DBNAME
csql -udba -c "select * from ${TBNAME}" $DBNAME;
cubrid server stop $DBNAME

cat $DB_SERVERLOG | grep "TDE:" | egrep -e "file_apply_tde_algorithm|file_set_tde_algorithm|file_alloc|pgbuf_set_tde_algorithm"
# EXPECTED:
# created temp file is encrypted by using AES
# tde_algorithm = AES for file_apply_tde_algorithm, file_set_tde_algorithm_internal, file_alloc, pgbuf_set_tde_algorithm
# ignore logs for tde_algorithm = NONE

cubrid deletedb $DBNAME
