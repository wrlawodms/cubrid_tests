#!/bin/bash

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

cubrid server start ${DBNAME}

csql -udba -c "create table tbl_enc (a int) encrypt=aes encrypt=aria" ${DBNAME}
csql -udba -c "create table tbl_enc (a int) encrypt=aas" ${DBNAME}

cubrid server stop ${DBNAME}
cubrid deletedb $DBNAME
