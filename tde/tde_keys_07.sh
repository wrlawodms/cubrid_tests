#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "alter user dba password 'test'" $DBNAME

cubrid tde -n $DBNAME # no password is given, EXPECTED: prompt to ask the password
cubrid tde -p "wrong" -n $DBNAME # a wrong password is given
# EXPECTED: Incorrect or missing password
cubrid tde -p "test" -n $DBNAME # a right password if given, EXPECTED: success

cubrid deletedb $DBNAME
