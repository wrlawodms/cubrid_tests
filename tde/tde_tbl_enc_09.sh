#!/bin/bash

TBNAME=tbl_test

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

cubrid server start ${DBNAME}

csql -udba -c "create table ${TBNAME}_1 (a int primary key) encrypt;" ${DBNAME}
csql -udba -c "create table ${TBNAME}_2 (a int, constraint pk_a primary key (a)) encrypt;" ${DBNAME}

cubrid server stop ${DBNAME}

cubrid diagdb -d1 ${DBNAME} | grep -C10 $TBNAME | egrep "tde_algorithm|type|CLASS_OID"
# EXPECTED: 2 heap file (HEAP_REUSE_SLOTS) and 2 btree file (BTREE)
# tde_algorithm of each pair is the same

cubrid deletedb $DBNAME
