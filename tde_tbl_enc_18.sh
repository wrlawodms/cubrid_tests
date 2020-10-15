#!/bin/bash

TBNAME=tbl_test

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

cubrid server start ${DBNAME}

csql -udba -c "create table ${TBNAME} (a int) encrypt;" ${DBNAME}
csql -udba -c "create table ${TBNAME}_son under ${TBNAME};" ${DBNAME}
csql -udba -c "create table ${TBNAME}_son_enc under ${TBNAME} encrypt=aria;" ${DBNAME}

csql -udba -c "select class_name, tde_algorithm from db_class where class_name like '${TBNAME}%'" ${DBNAME}
# EXPECTED: each of them has the different tde_algorithm (AES, NONE, ARIA)

cubrid server stop ${DBNAME}
cubrid deletedb $DBNAME
