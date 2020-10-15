#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

cubrid server start ${DBNAME}

csql -udba -c "create table a (a int) encrypt;" ${DBNAME}
csql -udba -c "insert into a (a) values(3);" ${DBNAME}
csql -udba -c "create table space (sp char(20000));" ${DBNAME}
csql -udba -c "insert into space (sp) values(' ');" ${DBNAME}

cubrid server stop ${DBNAME}

rm ${DBNAME}_keys

cubrid server start ${DBNAME}
# EXPECTED: success to start 

csql -udba -c "insert into a (a) values(4);" ${DBNAME}
csql -udba -c "select * from a;" ${DBNAME}
csql -udba -c "update a set a=4 where a=3;" ${DBNAME}
# EXPECTED: all the statements fail (ERROR: TDE module is not loaded)

cubrid server stop ${DBNAME}
cubrid deletedb $DBNAME
