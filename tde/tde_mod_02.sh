#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME ko_KR.utf8

echo "tde_keys_file_path=" >> $DBCONF

ls | grep ${DBNAME}_keys
# EXPECTED:
# must see the key file

cubrid deletedb $DBNAME
