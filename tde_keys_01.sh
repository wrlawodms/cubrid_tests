#!/bin/bash

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid tde  # manual check
cubrid tde -s $DBNAME # check default key, key index 0
cubrid tde -n $DBNAME # generate new key, key index 1
cubrid tde -c 1 $DBNAME # change key, key change 0 -> 1
cubrid tde -s $DBNAME # check default key, key index 1 is set, 0, 1 is shown
cubrid tde -d 0 $DBNAME # delete key
cubrid tde -s $DBNAME # show, key index 1 is set, only 1 is shown

cubrid deletedb $DBNAME
