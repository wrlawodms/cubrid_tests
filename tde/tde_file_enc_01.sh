#!/bin/bash

TBNAME=tbl_test

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

cubrid server start $DBNAME

csql -udba -c "create table $TBNAME (a char(2000)) dont_reuse_oid encrypt" $DBNAME;

for i in {1..5}
do
  csql -udba -c "insert into $TBNAME (a) values ('$i')" $DBNAME;
done

cubrid server stop $DBNAME

cubrid server start $DBNAME

csql -udba -c "drop table $TBNAME" $DBNAME;
csql -udba -c "create table $TBNAME (a char(2000)) encrypt" $DBNAME;

cubrid server stop $DBNAME

cat $DB_SERVERLOG | grep "TDE:" | egrep -e "file_apply_tde_algorithm|pgbuf_set_tde_algorithm|file_alloc"
# EXPECTED:
# The number of pgbuf_set_tde_algorithm() and the number of user pages in file_apply_tde_algorithm() is same
# there are three file_apply_tde_algorithm(), and the last two case is for this test ( # of user page = 5)

cubrid deletedb $DBNAME
