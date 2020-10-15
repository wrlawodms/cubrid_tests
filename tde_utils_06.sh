#!/bin/bash

TBNAME=test_tbl
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

ls

cubrid renamedb $DBNAME ${DBNAME}_renamed

ls    # EXPECTED: check renamed files including keys file

cubrid deletedb ${DBNAME}_renamed
