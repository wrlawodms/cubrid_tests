#!/bin/bash

TBNAME=tbl_test

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

cubrid server start $DBNAME

csql -udba -c "create table $TBNAME (a char(128))" $DBNAME;
csql -udba -c "create table ${TBNAME}_enc (a char(128)) encrypt" $DBNAME;

csql -udba -c "insert into $TBNAME (a) values ('TDE_TEST');" $DBNAME;
csql -udba -c "insert into ${TBNAME}_enc (a) values ('TDE_TEST_ENCRYPT');" $DBNAME;

cubrid server stop $DBNAME

set -x
cat $DBNAME | grep -w "TDE_TEST" # must match
cat $DBNAME | grep -w "TDE_TEST_ENCRYPT" # must not match
set +x

cubrid deletedb $DBNAME
