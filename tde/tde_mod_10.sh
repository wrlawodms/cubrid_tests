#!/bin/bash

TBNAME=tbl_test

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

cubrid server start $DBNAME

csql -udba -c "create table $TBNAME (a char(128))" $DBNAME;
csql -udba -c "create table ${TBNAME}_enc (a char(128)) encrypt" $DBNAME;

csql -udba -c "insert into $TBNAME (a) values ('TDE_TEST');" $DBNAME;
csql -udba -c "insert into ${TBNAME}_enc (a) values ('TDE_TEST_ENCRYPT');" $DBNAME;

cubrid server stop $DBNAME

set -x
cat $DBNAME | grep -w "TDE_TEST" 
# EXPECTED:
# TDE_TEST is not encrypted,
# so grep prints "matches"
cat $DBNAME | grep -w "TDE_TEST_ENCRYPT" # must not match
# EXPECTED:
# TDE_TEST_ENCRYPT has been encrypted,
# so grep prints nothing (can't find)

set +x

csql -udba -S -c "select * from ${TBNAME}_enc;" $DBNAME;
# EXPECTED:
# you can see the encrypted data ('TDE_TEST_ENCRYPT')

cubrid deletedb $DBNAME
