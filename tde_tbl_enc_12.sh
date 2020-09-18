#!/bin/bash

TBNAME=tbl_test

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

cubrid server start ${DBNAME}

csql -udba -c "create table ${TBNAME} (a int,b int) encrypt;" ${DBNAME}
csql -udba -c "alter table ${TBNAME} modify a int unique;" ${DBNAME}
csql -udba -c "alter table ${TBNAME} add key bk(b);" ${DBNAME}

cubrid server stop ${DBNAME}

cubrid diagdb -d1 ${DBNAME} | grep -C10 $TBNAME | egrep "tde_algorithm|type|CLASS_OID"

cubrid deletedb $DBNAME
