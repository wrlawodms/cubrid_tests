#!/bin/bash

TBNAME=tbl_test

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

cubrid server start $DBNAME

csql -udba -c "create table $TBNAME (a char(2000)) encrypt" $DBNAME;

for i in {1..5}
do
  csql -udba -c "insert into $TBNAME (a) values ('$i')" $DBNAME;
done

cubrid server stop $DBNAME

cat $DB_SERVERLOG | grep "TDE:" | egrep -e "file_alloc|pgbuf_set_tde_algorithm"
# EXPECTED:
# "pgbuf_set_tde_algorithm(): VPID = 0|3522, tde_algorithm = AES" 
# must follow 
# "TDE: file_alloc(): set tde bit in pflag, VFID = 0|3520, VPID = 0|3522, tde_algorithm of the file = AES"
# VFID doesn't matter, and VPID of each pair has to be the same"

cubrid deletedb $DBNAME
