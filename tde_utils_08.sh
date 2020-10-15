#!/bin/bash

TBNAME=test_tbl
KEYS_PATH=keys

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

# copy the key file to another directory
mkdir $KEYS_PATH
cp ${DBNAME}_keys ${KEYS_PATH}/
cd $KEYS_PATH
echo "tde_keys_file_path=`pwd`" >> $DBCONF
ls 
cd ..

cubrid deletedb ${DBNAME}
ls # EXPECTED: check if all the files inclding keys file has been deleted 
ls $KEYS_PATH # EXPECTED: check if copied key file still exists
