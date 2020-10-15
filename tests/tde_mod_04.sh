#!/bin/bash

KEYSDIR=keys
mkdir $KEYSDIR
echo "tde_keys_file_path=$DESTDIR" >> $DBCONF

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

ls $KEYSDIR | grep ${DBNAME}_keys
# EXPECTED: you must see the key file
ls | grep ${DBNAME}_keys
# EXPECTED: you can't see the key file

cubrid deletedb $DBNAME
