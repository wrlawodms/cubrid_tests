#!/bin/bash

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

mv ${DBNAME}_keys ${DBNAME}_tmp_keys

cubrid server start $DBNAME

mv ${DBNAME}_tmp_keys ${DBNAME}_keys

cubrid tde -C -s $DBNAME

cubrid server stop $DBNAME
cubrid deletedb $DBNAME
