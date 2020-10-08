#!/bin/bash

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid tde $DBNAME # one operation is required
cubrid tde -d $DBNAME # -d requires a key index
cubrid tde -c $DBNAMe # -c requires a key index

cubrid deletedb $DBNAME
