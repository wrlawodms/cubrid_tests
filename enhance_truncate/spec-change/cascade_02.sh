#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

cubrid server start $DBNAME

csql -udba -i cascade_02.sql $DBNAME

echo ""
echo "***** Expected: The TRUNCATE fails, and follwing select count(*) print 1 *****"
echo ""

cubrid server stop $DBNAME

# Descripttion:
#   CASCASDE fails if a grand-child (more 2 depth) doesn't have ON DELETE CASCADE option
#   case: A <- B <- E, F (ON DELETE RESTRICT)
#            L C <- G, H

# Expected:
# 1. The TRUNCATE fails, and follwing select count(*) print 1
#     - ERROR: Cannot cascade truncate because the ON DELETE action of the foreign key (fk_grand_child2_b) is not set to CASCADE.
cubrid deletedb $DBNAME
