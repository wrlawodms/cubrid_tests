#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

rm ${DBNAME}_keys

cubrid server start ${DBNAME}
# EXPECTED: succeed to start server

cat $DB_SERVERLOG | egrep -A1 "\-10|\-1254"
# EXPECTED: can see the 10, 1254 error (Cannot load TDE module)

cubrid server stop ${DBNAME}
cubrid deletedb $DBNAME
