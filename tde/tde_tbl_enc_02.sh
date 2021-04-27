#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

cubrid server start ${DBNAME}

csql -udba -c "create table tbl_enc (a int) encrypt=aes encrypt=aria" ${DBNAME}
# EXPECTED: Duplicate table option 'encrypt = ARIA'
csql -udba -c "create table tbl_enc (a int) encrypt=aas" ${DBNAME}
# EXPECTED: unexpcted 'aas'

cubrid server stop ${DBNAME}
cubrid deletedb $DBNAME
