#!/bin/bash

TBNAME=tbl_test

rm -rf $DBNAME
mkdir $DBNAME
cd $DBNAME
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME en_US

csql -udba -S -c "create table ${TBNAME} (a char(100)) encrypt;" $DBNAME
csql -udba -S -c "create table ${TBNAME}_big (a char (20000)) encrypt;" $DBNAME

cubrid server start $DBNAME

for i in {1000..2000}
do
echo "insert into ${TBNAME} (a) values('$i');" >> pre_build.sql 
done

echo "delete ${TBNAME};" >> delete_index.sql 

csql -udba -i pre_build.sql $DBNAME # prepare to build a index

cubrid server stop $DBNAME
echo "tde_trace_debug=1" >> $DBCONF
cubrid server start $DBNAME

for i in {0..20} # one insertion is enough, but for inserting with building index (race)
do
echo "insert into ${TBNAME} (a) values('$i');" >> post_build.sql 
echo "delete ${TBNAME} where a='$i';" >> post_build.sql 
done

csql -udba -c "create index idx_a on ${TBNAME} (a) with online parallel 1" $DBNAME & # RVBT_RECORD_MODIFY_NO_UNDO, RVBT_NDRECORD_INS

# post_build.sql has to be executed during building the index concurrently
csql -udba -i post_build.sql $DBNAME # RVBT_ONLINE_INDEX_UNDO_TRAN_INSERT/DELETE

fg

csql -udba -i delete_index.sql $DBNAME # RVBT_NDRECORD_DEL

cubrid server stop $DBNAME

cat csql.err | egrep -e "RVBT_ONLINE_INDEX_UNDO_TRAN_INSERT|RVBT_ONLINE_INDEX_UNDO_TRAN_DELETE|RVBT_RECORD_MODIFY_NO_UNDO";

cubrid deletedb $DBNAME
