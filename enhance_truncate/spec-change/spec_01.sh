#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid server start $DBNAME

csql -udba -i spec_01.sql $DBNAME

cubrid server stop $DBNAME

# Descripttion:
# NO FK cases

# Expected:
# 1. all statements succeeds
# 2. all select count(*) prints 0

cubrid deletedb $DBNAME
