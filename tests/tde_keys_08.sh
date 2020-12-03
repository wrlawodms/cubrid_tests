#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid server start $DBNAME

cubrid tde --CS-mode -s $DBNAME # EXPECTED:  check default key, key index 0
cubrid tde --CS-mode -n $DBNAME # EXPECTED: generate new key, key index 1
cubrid tde --CS-mode -c 1 $DBNAME # EXPECTED: change key, key change 0 -> 1
cubrid tde --CS-mode -s $DBNAME # EXPECTED: check default key, key index 1 is set, 0, 1 is shown
cubrid tde --CS-mode -d 0 $DBNAME # EXPECTED: delete key
cubrid tde --CS-mode -s $DBNAME # EXPECTED: show, key index 1 is set, only 1 is shown

cubrid server stop $DBNAME

cubrid deletedb $DBNAME
