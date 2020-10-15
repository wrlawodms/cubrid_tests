#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid tde --show-keys $DBNAME # EXPECTED: check default key, key index 0
cubrid tde --generate-new-key $DBNAME # EXPECTED: generate new key, key index 1
cubrid tde --change-key=1 $DBNAME # EXPECTED: change key, key change 0 -> 1
cubrid tde --show-keys $DBNAME # EXPECTED: check default key, key index 1 is set, 0, 1 is shown
cubrid tde --delete-key 0 $DBNAME # EXPECTED: delete key
cubrid tde --show-keys $DBNAME # EXPECTED: show, key index 1 is set, only 1 is shown

cubrid deletedb $DBNAME
