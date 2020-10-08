#!/bin/bash

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "alter user dba password 'test'" $DBNAME

cubrid tde -n $DBNAME # no password is given
cubrid tde -p "wrong" -n $DBNAME # a wrong password is given
cubrid tde -p "test" -n $DBNAME # a right password if given

cubrid deletedb $DBNAME
