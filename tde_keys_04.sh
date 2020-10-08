#!/bin/bash

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid tde -s $DBNAME
cubrid tde -d 0 $DBNAME # fail to delete the key(0) used on database 

cubrid deletedb $DBNAME
