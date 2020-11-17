#!/bin/bash

# SORT_PARAM test

TBNAME=tbl_test
SRC_TBNAME=tbl_test_src

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME en_US

cubrid server start $DBNAME

csql -udba -c "create table ${TBNAME}(a int, b int);" $DBNAME;
for i in {1..2}
do
  csql -udba -c "insert into ${TBNAME}(a, b) values (${i}, ${i}0);" $DBNAME;
done

csql -udba -c "create table ${TBNAME}_enc(a int, b int) encrypt;" $DBNAME;
for i in {1..2}
do
  csql -udba -c "insert into ${TBNAME}_enc(a, b) values (${i}, ${i}0);" $DBNAME;
done

cubrid server stop $DBNAME

csql -udba -S -c "select * from ${TBNAME} order by b;" $DBNAME                    # order by
csql -udba -S -c "select avg(a), b from ${TBNAME} group by b;" $DBNAME            # group by
csql -udba -S -c "select avg(a) over (partition by b) from ${TBNAME};" $DBNAME    # analytics
csql -udba -S -c "create index ${TBNAME}_idx on ${TBNAME} (a);" $DBNAME           # load index

csql -udba -S -c "select * from ${TBNAME}_enc order by b;" $DBNAME                    # order by
csql -udba -S -c "select avg(a), b from ${TBNAME}_enc group by b;" $DBNAME            # group by
csql -udba -S -c "select avg(a) over (partition by b) from ${TBNAME}_enc;" $DBNAME    # analytics
csql -udba -S -c "create index ${TBNAME}_enc_idx on ${TBNAME}_enc (a);" $DBNAME           # load index

cat csql.err | grep "TDE:" | egrep -e "sort_listfile"
# EXPECTED:
# for a normal table: 
#   TDE: sort_listfile(): tde_encrypted = 0, 0, 0, 0
# for an encrypted table:
#   TDE: sort_listfile(): tde_encrypted = 1, 1, 1, 1

cubrid deletedb $DBNAME
