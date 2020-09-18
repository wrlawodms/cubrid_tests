#!/bin/bash

TBNAME=tbl_test

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

cubrid server start ${DBNAME}

csql -udba -c "create table ${TBNAME} (a int) encrypt;" ${DBNAME}
csql -udba -c "create table ${TBNAME}_son under ${TBNAME};" ${DBNAME}

cubrid server stop ${DBNAME}

rm ${DBNAME}_keys 

cubrid server start ${DBNAME}

csql -udba -c "insert into ${TBNAME} (a) values(3);" ${DBNAME}

cubrid server stop ${DBNAME}

cubrid deletedb $DBNAME
