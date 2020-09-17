#!/bin/bash

TBNAME=tbl_test

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

cubrid server start ${DBNAME}

csql -udba -c "create table ${TBNAME} (a int) encrypt;" ${DBNAME}
csql -udba -c "create table ${TBNAME}_aes (a int) encrypt=AES;" ${DBNAME}
csql -udba -c "create table ${TBNAME}_aria (a int) encrypt=ARIA;" ${DBNAME}
csql -udba -c "show create table ${TBNAME};" ${DBNAME}
csql -udba -c "show create table ${TBNAME}_aes;" ${DBNAME}
csql -udba -c "show create table ${TBNAME}_aria;" ${DBNAME}

cubrid server stop ${DBNAME}
cubrid deletedb $DBNAME
