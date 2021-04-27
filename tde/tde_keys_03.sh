#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

for i in {0..10}
do
  cubrid tde -n $DBNAME # generate new keys
done

cubrid tde -s $DBNAME
cubrid tde -d 5 $DBNAME
cubrid tde -d 8 $DBNAME
cubrid tde -s $DBNAME    
cubrid tde -n $DBNAME    # use the smallest emptry slot (5)
cubrid tde -s $DBNAME    # EXPECTED: you can see the empty slot (5) has been used.

cubrid deletedb $DBNAME
