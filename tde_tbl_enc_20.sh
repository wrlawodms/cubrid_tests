#!/bin/bash

TBNAME=tbl_test

mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

cubrid server start ${DBNAME}

csql -udba -c "create table ${TBNAME}_hash (a int) encrypt PARTITION BY HASH (a) PARTITIONS 2;" ${DBNAME}
csql -udba -c "create table ${TBNAME}_range (a int) encrypt=AES PARTITION BY range (a) (PARTITION under_0 values less than (0), partition under_10 values less than (10));" ${DBNAME}
csql -udba -c "create table ${TBNAME}_list (a int) encrypt=ARIA PARTITION BY LIST (a) (partition zeroone values in (0,1), partition two values in (2));" ${DBNAME}
csql -udba -c "select class_name, tde_algorithm from db_class where class_name like '${TBNAME}%'" ${DBNAME}

cubrid server stop ${DBNAME}
cubrid deletedb $DBNAME
