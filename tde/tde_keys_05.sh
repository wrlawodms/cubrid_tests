#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid tde -n $DBNAME
cubrid tde -s $DBNAME # (A)
cubrid tde -d 2 $DBNAME # EXPECTED: fail to delete a key which doesn't exist
cubrid tde -s $DBNAME # EXPECTED: have to be the same state as (A)

cubrid deletedb $DBNAME
