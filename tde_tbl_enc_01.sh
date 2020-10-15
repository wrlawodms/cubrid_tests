#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

cubrid server start ${DBNAME}

csql -udba -c "create table tbl_no_enc (a int)" ${DBNAME}
csql -udba -c "create table tbl_enc (a int) encrypt" ${DBNAME}
csql -udba -c "create table tbl_enc_aes (a int) encrypt=aes" ${DBNAME}
csql -udba -c "create table tbl_enc_aria (a int) encrypt=aria" ${DBNAME}

csql -udba -c "select class_name, tde_algorithm from db_class where class_name like 'tbl_%'" ${DBNAME}
# EXPECTED: 
# tde_algorithm: NONE, AES, AES, ARIA 
# corresponding to tbl_no_enc, tbl_enc, tbl_enc_aes, tbl_enc_aria 

csql -udba -c "select class_name, tde_algorithm from _db_class where class_name like 'tbl_%'" ${DBNAME}
# EXPECTED: 
# tde_algorithm: 0, 1, 1, 2
# corresponding to tbl_no_enc, tbl_enc, tbl_enc_aes, tbl_enc_aria 

cubrid server stop ${DBNAME}
cubrid deletedb $DBNAME
