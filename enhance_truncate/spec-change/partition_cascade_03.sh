#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid server start $DBNAME

echo "***** Expected: The TRUNCATE succeeds, and follwing select count(*) print 0 *****"
csql -udba -i partition_cascade_03.sql $DBNAME

cubrid server stop $DBNAME

# Descripttion:
#   CASCASDE succeeds if there is a FK chain
#   case: A <- B <- C
#         L_________^

# Expected:
# 1. The TRUNCATE succeeds, and follwing select count(*) print 0

cubrid deletedb $DBNAME
