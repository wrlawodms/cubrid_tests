#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8
cubrid createdb --db-volume-size=128M --log-volume-size=128M ${DBNAME}_tmp ko_KR.utf8

cp ${DBNAME}_tmp_keys ${DBNAME}_keys

cubrid server start ${DBNAME}
# EXPECTED: succeed to start server

cat $DB_SERVERLOG | egrep -A1 "\-1254|\-1249"
# EXPECTED: can see the 1249, 1254 error (Cannot load TDE module)

cubrid server stop ${DBNAME}

cubrid deletedb ${DBNAME}_tmp
cubrid deletedb $DBNAME
