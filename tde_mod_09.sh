#!/bin/bash

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

csql -udba -S -c "create table a (a int) encrypt" ${DBNAME}
csql -udba -S -c "insert into a (a) values(3)" ${DBNAME}

DESTDIR=`pwd`/keypath
mkdir $DESTDIR
mv ${DBNAME}_keys $DESTDIR/${DBNAME}_keys
echo "tde_keys_file_path=$DESTDIR" >> $DBCONF

csql -udba -S -c "select * from a;" ${DBNAME}

cubrid deletedb $DBNAME
