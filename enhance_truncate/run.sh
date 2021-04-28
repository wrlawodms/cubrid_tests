#!/bin/bash

DBNAME=tt_testdb
DBCONF=$CUBRID_DATABASES/../conf/cubrid.conf
DBLOG=$CUBRID/log
DB_SERVERLOG=$DBLOG/server/${DBNAME}_latest.err
DB_SERVERLOGS_FOR_DELETE=$DBLOG/server/${DBNAME}_*.err
USINGCONF=cubrid.conf
WORKING_DIR=$1
TEST=$2

echo ""
echo "CUBRID: $CUBRID"
echo "CUBRID_DATABASES: $CUBRID_DATABASES"
echo "DBNAME: $DBNAME"
echo "DBCONF: $DBCONF"
echo "USINGCONF: $USINGCONF"
echo "TEST: $TEST"
echo ""

#set -x

cubrid server stop $DBNAME
cubrid deletedb $DBNAME
rm ${DBLOG}/${DBNAME}_*.*
rm $DB_SERVERLOGS_FOR_DELETE
rm -rf $DBNAME
mkdir $DBNAME

cp $USINGCONF $DBCONF
cd $DBNAME

cd ../$WORKING_DIR

source ../$TEST
