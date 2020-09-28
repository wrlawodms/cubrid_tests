#!/bin/bash

# SORT_PARAM test

TBNAME=tbl_test
SRC_TBNAME=tbl_test_src

rm -r $DBNAME
mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME en_US

cubrid server start $DBNAME

csql -udba -c "create table ${TBNAME}(a int, b int) encrypt;" $DBNAME;
for i in {1..2}
do
  csql -udba -c "insert into ${TBNAME}(a, b) values (${i}, ${i}0);" $DBNAME;
done

cubrid server stop $DBNAME

echo "tde_trace_debug=1" >> $DBCONF

csql -udba -S -c "select * from ${TBNAME} order by b;" $DBNAME                    # order by
csql -udba -S -c "select avg(a), b from ${TBNAME} group by b;" $DBNAME            # group by
csql -udba -S -c "select avg(a) over (partition by b) from ${TBNAME};" $DBNAME    # analytics
csql -udba -S -c "create index ${TBNAME}_idx on ${TBNAME} (a);" $DBNAME           # load index

cubrid deletedb $DBNAME
