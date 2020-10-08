#!/bin/bash

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid tde -n $DBNAME
cubrid tde -s $DBNAME # (A)
cubrid tde -c 2 $DBNAME # fail to change to what doesn't exist
cubrid tde -s $DBNAME # have to be the same state as (A)

cubrid deletedb $DBNAME
