#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid server start $DBNAME

echo "***** Expected 1. The first TRUNCATE fails, and follwing select count(*) print 1 *****"
echo "***** Expected 2. The second TRUNCATE succeeds, and follwing select count(*) print 0 *****"
csql -udba -i cascade_01.sql $DBNAME

cubrid server stop $DBNAME

# Descripttion:
#   CASCASDE succeeds even if a FK-child has a FK-child (2-depth)
#   case: A <- B <- E, F
#            L C <- G, H

# Expected:
# 1. The first TRUNCATE fails, and follwing select count(*) print 1
# 2. The second TRUNCATE succeeds, and follwing select count(*) print 0
cubrid deletedb $DBNAME
