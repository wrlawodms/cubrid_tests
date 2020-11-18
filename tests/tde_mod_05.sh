#!/bin/bash

touch ${DBNAME}_keys
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8
# EXPECTED: fail to create the database
cat $DBLOG/${DBNAME}_createdb.err | egrep -A1 -e "-1248,"
# EXPECTED: you can see the error 1248 (Invalid Key file)
