#!/bin/bash

TBNAME=test_tbl

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table $TBNAME (a int) encrypt" $DBNAME

cubrid unloaddb -S -s -udba $DBNAME
csql -udba -S -c "drop table $TBNAME" $DBNAME
cubrid loaddb -udba -S -s ${DBNAME}_schema $DBNAME

csql -udba -S -c "select class_name, tde_algorithm from db_class where class_name='$TBNAME'" $DBNAME
# EXPECTED: tde_algorithm = AES

cubrid deletedb $DBNAME
