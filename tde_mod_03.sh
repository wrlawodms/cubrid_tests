#!/bin/bash

DESTDIR=`pwd`/keypath
mkdir $DESTDIR
cd $DESTDIR
echo "tde_keys_file_path=$DESTDIR" >> $DBCONF

cubrid deletedb ${DBNAME}
cubrid deletedb ${DBNAME}_other

cd -
mkdir $DBNAME
cd $DBNAME

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

cp ${DESTDIR}/${DBNAME}_keys ${DESTDIR}/${DBNAME}_other_keys

cubrid createdb --db-volume-size=128M --log-volume-size=64M ${DBNAME}_other ko_KR.utf8

ls $DESTDIR | grep ${DBNAME}_keys
ls | grep ${DBNAME}_keys
ls | grep ${DBNAME}_other_keys

cubrid tde -s $DBNAME
cubrid tde -s ${DBNAME}_other

cubrid deletedb $DBNAME
cubrid deletedb ${DBNAME}_other
rm -rf $DESTDIR
