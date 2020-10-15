#!/bin/bash

TBNAME=tbl_test
SRC_TBNAME=tbl_test_src

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME en_US

cubrid server start $DBNAME

csql -udba -c "create table ${TBNAME}(a char(17000)) encrypt;" $DBNAME;
for i in {1..5}
do
  csql -udba -c "insert into ${TBNAME}(a) values (' ');" $DBNAME;
done

cubrid server stop $DBNAME

echo "file_logging_debug=1" >> $DBCONF

csql -udba -S -c "create index ${TBNAME}_idx on ${TBNAME} (a);" $DBNAME | grep -A3 "file_apply_tde_algorithm"

cat csql.err | grep -A3 "FILE file_create (SA_MODE): finished creating file."
cat csql.err | grep "TDE:" | egrep -e "file_apply_tde_algorithm"
# EXPECTED:
# All the temp file created while building index has to be encrypted.
# the VFID printed file_log and the VFID in "TDE:" has to match, and the number of them has to match
# Consider only logs in which tde algorithm = AES

cubrid deletedb $DBNAME
