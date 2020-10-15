#!/bin/bash

TBNAME=test_tbl

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

echo "tde_default_algorithm=ARIA" >> $DBCONF

cubrid paramdump -S $DBNAME | egrep -e "tde_keys_file_path|tde_default_algorithm"
# EXPECTED: you can see tde_keys_file_path, tde_default_algorithm

cubrid deletedb $DBNAME
