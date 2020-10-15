#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

mv ${DBNAME}_keys ${DBNAME}_tmp_keys

cubrid server start $DBNAME

mv ${DBNAME}_tmp_keys ${DBNAME}_keys

cubrid tde -C -s $DBNAME
# EXPECTED: 
# In The current key set on testdb SECTION: TDE Moudle is not loaded.
# In the below, success to print key info in the key file

cubrid server stop $DBNAME
cubrid deletedb $DBNAME
