#!/bin/bash

TBNAME=test_tbl

cubrid deletedb $DBNAME

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid deletedb ${DBNAME}
ls # EXPECTED: check if all the files inclding keys file has benn deleted 
