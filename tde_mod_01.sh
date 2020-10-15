#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

ls | grep ${DBNAME}_keys
# EXPECTED:
# must show the key file

cubrid deletedb $DBNAME
