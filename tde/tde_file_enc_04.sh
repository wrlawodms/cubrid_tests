#!/bin/bash

TBNAME=tbl_test

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

cubrid server start $DBNAME

csql -udba -c "create table $TBNAME (a char(2000)) dont_reuse_oid encrypt" $DBNAME;

for i in {1..5}
do
  csql -udba -c "insert into $TBNAME (a) values ('$i')" $DBNAME;
done

csql -udba -c "drop table $TBNAME" $DBNAME;

csql -udba -c "create table $TBNAME (a char(2000)) dont_reuse_oid" $DBNAME;
cat $DB_SERVERLOG | grep "TDE:" | egrep -e "file_apply_tde_algorithm|pgbuf_set_tde_algorithm"
# EXPECTED: the number of pgbuf_set_tde_algorithm() after file_apply_tde_algorithm() (NONE) is the same as the number of user pages (5)

cubrid server stop $DBNAME
cubrid deletedb $DBNAME
