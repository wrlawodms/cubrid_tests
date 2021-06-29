#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid server start $DBNAME

csql -udba -i spec_04.sql $DBNAME
echo "***** Following expected results (1~4) repeat 7 times *****"
echo "***** Expected 1: the first SELECT prints 0 *****"
echo "***** Expected 2: the following SELECT prints >= 1 *****"

cubrid server stop $DBNAME

# Descripttion:
#   Rollback test 
#   4 cases: Normal, Inheritance, Paritioning, REUSABLE or not

# Expected:
# 1. the first two selects count(*) prints 0
# 2. the following two selects count(*) prints >= 1
# (1)~(2) repeat 7 times

cubrid deletedb $DBNAME
