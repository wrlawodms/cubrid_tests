#!/bin/bash

TBNAME=test_tbl
COPY_DBNAME=${DBNAME}_copy

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table $TBNAME (a int) encrypt" $DBNAME
csql -udba -S -c "insert into $TBNAME (a) values(3)" $DBNAME

mkdir $COPY_DBNAME
cd $COPY_DBNAME
cubrid copydb --delete-source $DBNAME $COPY_DBNAME

csql -udba -S -c "select class_name, tde_algorithm from db_class where class_name='$TBNAME'" $COPY_DBNAME # Check if the tde info is copied properly
csql -udba -S -c "select * from $TBNAME" $COPY_DBNAME # Check if it can access encrypted table

cd ..
ls    # there has to be no $DBNAME database including the key file

cubrid deletedb $DBNAME
cubrid deletedb $COPY_DBNAME
