#!/bin/bash

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME

DESTDIR=`pwd`/keypath
mkdir $DESTDIR
cd $DESTDIR
echo "tde_keys_file_path=$DESTDIR" >> $DBCONF

cd -
cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

ls $DESTDIR | grep ${DBNAME}_keys
ls | grep ${DBNAME}_keys

cubrid deletedb $DBNAME
rm -rf $DESTDIR
