#!/bin/bash

TBNAME=tbl_test

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

cubrid server start ${DBNAME}

csql -udba -c "create table ${TBNAME}_1 (a int, index a(a)) encrypt;" ${DBNAME}
csql -udba -c "create table ${TBNAME}_2 (a int unique) encrypt;" ${DBNAME}
csql -udba -c "create table ${TBNAME}_3 (a int, constraint unique(a)) encrypt;" ${DBNAME}

cubrid server stop ${DBNAME}

cubrid diagdb -d1 ${DBNAME} | grep -C10 $TBNAME | egrep "tde_algorithm|type|CLASS_OID"
# EXPECTED: 3 heap file (HEAP_REUSE_SLOTS) and 3 btree file (BTREE)
# tde_algorithm of each pair is the same

cubrid deletedb $DBNAME
