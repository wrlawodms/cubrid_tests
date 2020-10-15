#!/bin/bash

KEYSDIR=keys

mkdir $KEYSDIR

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8
cubrid tde -s $DBNAME # (A)

echo "tde_keys_file_path=$KEYSDIR" >> $DBCONF
cp ${DBNAME}_keys ${KEYSDIR}/${DBNAME}_other_keys

sleep 1 # to identify key files by created time

cubrid createdb --db-volume-size=128M --log-volume-size=64M ${DBNAME}_other ko_KR.utf8
cubrid tde -s ${DBNAME}_other # (B)
# EXPECTED: (A) and (B) has to use same key file
# for the key set on the databases,
# the created time has to be same and the set time has to be different

cubrid deletedb $DBNAME
cubrid deletedb ${DBNAME}_other
