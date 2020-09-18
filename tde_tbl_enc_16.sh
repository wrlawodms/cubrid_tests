#!/bin/bash

TBNAME=tbl_test

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

cubrid server start ${DBNAME}

csql -udba -c "create table ${TBNAME} (a int) encrypt=aria;" ${DBNAME}
csql -udba -c "create table ${TBNAME}_like like ${TBNAME}" ${DBNAME}
csql -udba -c "select class_name, tde_algorithm from db_class where class_name like '${TBNAME}%'" ${DBNAME}

cubrid server stop ${DBNAME}
cubrid deletedb $DBNAME
