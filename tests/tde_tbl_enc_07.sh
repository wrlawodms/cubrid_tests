#!/bin/bash

TBNAME=tbl_test

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

cubrid server start ${DBNAME}

csql -udba -c "create table $TBNAME (a int) encrypt;" ${DBNAME}

cubrid server stop ${DBNAME}

cubrid diagdb -d1 ${DBNAME} | grep -C10 $TBNAME | egrep "tde_algorithm|type|CLASS_OID"
# EXPECTED: only one heap file, of which tde_algorithm is AES

cubrid deletedb $DBNAME
