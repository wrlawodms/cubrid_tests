#!/bin/bash

TBNAME=test_tbl
COPY_DBNAME=${DBNAME}_copy

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table $TBNAME (a int) encrypt" $DBNAME
csql -udba -S -c "insert into $TBNAME (a) values(3)" $DBNAME

mkdir $COPY_DBNAME
cd $COPY_DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $COPY_DBNAME en_US

ls

cubrid copydb --replace $DBNAME $COPY_DBNAME

csql -udba -S -c "select class_name, tde_algorithm from db_class where class_name='$TBNAME'" $COPY_DBNAME # EXPECTED: the tde_algorithm = AES
csql -udba -S -c "select * from $TBNAME" $COPY_DBNAME # EXPECTED: it can access encrypted table

cubrid deletedb $DBNAME
cubrid deletedb $COPY_DBNAME
