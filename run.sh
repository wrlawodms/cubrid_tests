#!/bin/bash

DBNAME=testdb
DBCONF=$CUBRID_DATABASES/../conf/cubrid.conf
DBLOG=$CUBRID/log
DB_SERVERLOG=$DBLOG/server/${DBNAME}_latest.err
USINGCONF=cubrid.conf
TEST=$1

echo ""
echo "CUBRID: $CUBRID"
echo "CUBRID_DATABASES: $CUBRID_DATABASES"
echo "DBNAME: $DBNAME"
echo "DBCONF: $DBCONF"
echo "USINGCONF: $USINGCONF"
echo "TEST: $TEST"
echo ""

#set -x

cubrid server stop ${DBNAME}

cp $USINGCONF $DBCONF

source $TEST
