#!/bin/bash

TBNAME=tbl_test

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

cubrid server start ${DBNAME}

csql -udba -c "create table $TBNAME (a int, b char(20000)) encrypt;" ${DBNAME}
csql -udba -c "insert into $TBNAME (a, b) values(0, 'big');" ${DBNAME}

cubrid server stop ${DBNAME}

cubrid diagdb -d1 ${DBNAME} | egrep -C14 "$TBNAME|Overflow" | egrep "tde_algorithm|type|CLASS_OID|Overflow|vfid"
# EXPECTED: 
# 2 files, one of which is heap (HEAP_REUSE_SLOTS) and the other is overflow heap (MULTIPAGE_OBJECT_HEAP)
# tde_algorithm of both is the same (AES)

cubrid deletedb $DBNAME
