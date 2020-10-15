#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid tde -s $DBNAME # (A)
cubrid tde -d 0 $DBNAME # EXPECTED: fail to delete the key(0) used on database 
cubrid tde -s $DBNAME # EXPECTED: have to be the same state as (A)

cubrid deletedb $DBNAME
