#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

# EXPECTED: you can see the hash values of the key in the commands below:
cubrid tde -n --print-value $DBNAME # generate new key, -v = --print-value
cubrid tde -s --print-value $DBNAME # it's only for -n, -s

cubrid deletedb $DBNAME
