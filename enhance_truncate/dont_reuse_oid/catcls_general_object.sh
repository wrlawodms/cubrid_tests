#!/bin/bash

CATCLS_SQL="SELECT COUNT(*) FROM [_db_domain] WHERE [data_type]=5 AND [class_of] IS NULL"
#
# !!CAUTION!!
# If [data_type] is DB_TYPE_OBEJCT and [class_of] is NULL, it is a gerneral object domain.
# We MUST confirm that the number of general object domains in system catalog classes like _db_domain is 5.
# If this number is changed, we have to change truncate_heap() function together. This is for optimization for TRUNCATE to classes with the DONT_REUSE_OID option. If you face the failure of this case, you might've either added or removed a general object domain in some system catalog class.
# This test case is to check this number.
#
# See CBRD-23983 for the details.
#

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

echo "======= expected 1: no user tables ========"
csql -udba -S -c "show tables" $DBNAME # expected 1: no user tables

echo "======= expected 2: count(*): 5 ========"
csql -udba -S -c "$CATCLS_SQL" $DBNAME # expected 2: count(*): 5

# Descripttion:
# see the CAUTION comment above and the comment should be put in real regression test script.

# Expected:
# 2 expected results. See each comments above

cubrid deletedb $DBNAME
