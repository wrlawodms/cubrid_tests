#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

rm ${DBNAME}_keys

cubrid server start ${DBNAME}
# EXPECTED: success to start

csql -udba -c "create table a (a int) encrypt" ${DBNAME}
# EXPECTED: 
# ERROR: TDE Module is not loaded.

cubrid server stop ${DBNAME}
cubrid deletedb $DBNAME
