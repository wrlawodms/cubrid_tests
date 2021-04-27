#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

for i in {1..127}
do
cubrid tde -n $DBNAME
done

cubrid tde -n $DBNAME
# EXPECTED: "FAILURE: The key file is full."

cubrid deletedb $DBNAME
