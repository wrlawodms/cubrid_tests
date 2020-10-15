#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

# EXPECTED: All the commands below fail, which print usage.
cubrid tde $DBNAME # one operation is required
cubrid tde -d $DBNAME # -d requires a key index
cubrid tde -c $DBNAMe # -c requires a key index

cubrid deletedb $DBNAME
