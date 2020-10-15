#!/bin/bash

TBNAME=tbl_test

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

cubrid server start $DBNAME

csql -udba -c "create table $TBNAME (a char(20000)) reuse_oid encrypt" $DBNAME;
csql -udba -c "insert into $TBNAME (a) values (' ')" $DBNAME;
csql -udba -c "drop table $TBNAME" $DBNAME

cubrid server stop $DBNAME

cat $DB_SERVERLOG | grep "TDE:" | egrep -e "pgbuf_set_tde_algorithm|pgbuf_dealloc_page|file_destroy"
# EXPECTED:
# The number of "TDE: pgbuf_set_tde_algorithm()", the number of "TDE: pgbuf_dealloc_page()" # ,and the number of user pages in TDE: file_destroy()"
# must match.

cubrid deletedb $DBNAME
