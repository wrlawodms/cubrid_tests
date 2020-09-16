#!/bin/bash

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

rm ${DBNAME}_keys

cubrid server start ${DBNAME}

csql -udba -c "create table a (a int) encrypt" ${DBNAME}

cubrid server stop ${DBNAME}
cubrid deletedb $DBNAME
