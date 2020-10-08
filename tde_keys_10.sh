#!/bin/bash

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid tde -n -v $DBNAME # generate new key, -v = --print-value
cubrid tde -s --print-value $DBNAME # it's only for -n, -s

cubrid deletedb $DBNAME
