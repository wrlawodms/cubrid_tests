#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid server start $DBNAME

csql -udba -i spec_03.sql $DBNAME

cubrid server stop $DBNAME

# Descripttion:
#   TRUNCATE when there is a FK with ON DELETE CASCADE option

# Expected:
# 1. the first truncate fails with "ERROR: Cannot truncate the table due to the primary key referred to on fk_child_a. Try again with CASCADE option."
# 2. the first select count(*) prints 1
# 3. the second truncate succeeds
# 4. the second selects count(*) prints 0,0

cubrid deletedb $DBNAME
