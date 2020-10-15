#!/bin/bash

touch ${DBNAME}_keys
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8
# EXPECTED: fail to create the database
cat $DBLOG/${DBNAME}_createdb.err | grep -A1 1247
# EXPECTED: you can see the error 1247 (Invalid Key file)
