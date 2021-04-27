#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

cubrid server start ${DBNAME}

csql -udba -c "create table tbl_enc (a int) encrypt=aes" ${DBNAME}
csql -udba -c "alter table tbl_enc encrypt=aes" ${DBNAME}
csql -udba -c "alter table tbl_enc encrypt=aria" ${DBNAME}
csql -udba -c "alter table tbl_enc encrypt" ${DBNAME}
# EXPECTED: 
# all the three alter statements fail (Syntax error)
# unexpected 'encrypt'

csql -udba -c "create table tbl_no_enc (a int)" ${DBNAME}
csql -udba -c "alter table tbl_no_enc encrypt=AES" ${DBNAME}
csql -udba -c "alter table tbl_no_enc encrypt" ${DBNAME}
# EXPECTED: 
# all the two alter statements fail (Syntax error)
# unexpected 'encrypt'

csql -udba -c "select class_name, tde_algorithm from db_class where class_name like 'tbl_%'" ${DBNAME}
# EXPECTED: 
# tde_algorithm hasn't changed.
# tbl_enc: AES, tbl_no_enc: NONE

cubrid server stop ${DBNAME}
cubrid deletedb $DBNAME
