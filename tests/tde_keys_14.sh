#!/bin/bash

KEYS_FILE=${DBNAME}_keys

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid tde -n $DBNAME

echo "a" >> $KEYS_FILE 

cubrid tde -n $DBNAME
# EXPECTED: "FAILURE: Invalid Key file :"

cubrid deletedb $DBNAME
