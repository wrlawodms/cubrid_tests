#!/bin/bash

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME

touch ${DBNAME}_keys
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8
