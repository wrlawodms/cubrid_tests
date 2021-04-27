#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

# EXPECTED: All the commands below fail, which print usage.
cubrid tde -s -n $DBNAME
cubrid tde -s -d 0 $DBNAME 
cubrid tde -s -c 0 $DBNAME
cubrid tde -n -d 0 $DBNAME
cubrid tde -n -c 0 $DBNAME
cubrid tde -d 0 -c 0 $DBNAME

cubrid deletedb $DBNAME
