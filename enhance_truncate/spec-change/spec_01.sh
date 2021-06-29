#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid server start $DBNAME

csql -udba -i spec_01.sql $DBNAME
echo "---------- EXPECTED: all statements succeed, and prints 0 ------"

cubrid server stop $DBNAME

# Descripttion:
# NO FK cases and self-referencing case

# Expected:
# 1. all statements succeeds
# 2. all select count(*) prints 0

cubrid deletedb $DBNAME
