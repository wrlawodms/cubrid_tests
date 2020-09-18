#!/bin/bash

TBNAME=tbl_test

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

cubrid server start ${DBNAME}

csql -udba -c "create table $TBNAME (a int, b char(20000)) encrypt;" ${DBNAME}
csql -udba -c "insert into $TBNAME (a, b) values(0, 'big');" ${DBNAME}

cubrid server stop ${DBNAME}

cubrid diagdb -d1 ${DBNAME} | egrep -C14 "$TBNAME|Overflow" | egrep "tde_algorithm|type|CLASS_OID|Overflow|vfid"

cubrid deletedb $DBNAME
