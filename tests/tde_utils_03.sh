#!/bin/bash

TBNAME=test_tbl
COPY_DBNAME=${DBNAME}_copy
KEYS_PATH=keys

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

# copy the key file to another directory
mkdir $KEYS_PATH
mv ${DBNAME}_keys ${KEYS_PATH}/
cd $KEYS_PATH
echo "tde_keys_file_path=`pwd`" >> $DBCONF
cd ..

csql -udba -S -c "create table $TBNAME (a int) encrypt" $DBNAME
csql -udba -S -c "insert into $TBNAME (a) values(3)" $DBNAME

mkdir $COPY_DBNAME
cd $COPY_DBNAME
cubrid copydb $DBNAME $COPY_DBNAME

csql -udba -S -c "select class_name, tde_algorithm from db_class where class_name='$TBNAME'" $COPY_DBNAME # EXPECTED: the tde_algorithm = AES
csql -udba -S -c "select * from $TBNAME" $COPY_DBNAME # EXPECTED: it can access encrypted table


cd ..
ls $COPY_DBNAME # EXPECTED: there has to be no key file
ls $KEYS_PATH   # EXPECTED: there has to be copied key file

cubrid deletedb $DBNAME
cubrid deletedb $COPY_DBNAME
