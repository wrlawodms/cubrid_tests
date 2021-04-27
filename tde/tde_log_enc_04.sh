#!/bin/bash

TBNAME=tbl_test

cubrid createdb --db-volume-size=128M --log-volume-size=64M $DBNAME en_US

set -x

csql -udba -S -c "create table ${TBNAME} (a int) encrypt;" $DBNAME
csql -udba -S -c "create table ${TBNAME}_uni (a int primary key) encrypt;" $DBNAME
csql -udba -S -c "create table ${TBNAME}_big (a char (20000)) encrypt;" $DBNAME
csql -udba -S -c "create table ${TBNAME}2 (a int) encrypt;" $DBNAME
csql -udba -S -c "create table ${TBNAME}2_big (a char (20000)) encrypt;" $DBNAME
csql -udba -S -c "create table ${TBNAME}_part (a int) encrypt partition by range (a)\
  (partition less_10 values less than (10), partition less_29 values less than (29));" $DBNAME
csql -udba -S -c "insert into ${TBNAME}_part (a) values (5), (15), (25);" $DBNAME

csql -udba -S -c "insert into ${TBNAME} (a) values(3)" $DBNAME # RVHF_INSERT
csql -udba -S -c "insert into ${TBNAME} (a) values(5)" $DBNAME 
csql -udba -S -c "update ${TBNAME} set a=4 where a=3" $DBNAME # RVHF_UPDATE
csql -udba -S -c "delete ${TBNAME} where a=4" $DBNAME # RVHF_DELETE

csql -udba -S -c "insert into ${TBNAME} (a) values(4)" $DBNAME
csql -udba -S -c "alter table ${TBNAME} add column b char(10000)" $DBNAME
csql -udba -S -c "update ${TBNAME} set b='b' where a=4" $DBNAME
csql -udba -S -c "update ${TBNAME} set b='b' where a=5" $DBNAME # RVHF_INSERT_NEWHOME

csql -udba -S -c "insert into ${TBNAME}_big (a) values('a')" $DBNAME # RVOVF_NEWPAGE_INSERT
csql -udba -S -c "update ${TBNAME}_big set a='b' where a='a'" $DBNAME # RVHF_PAGE_UPDATE

csql -udba -S -c "create index idx_a on ${TBNAME} (a)" $DBNAME # RVBT_COPYPAGE
csql -udba -S -c "insert into ${TBNAME} (a) values(6)" $DBNAME # RVBT_NON_MVCC_INSERT_OBJECT
csql -udba -S -c "delete ${TBNAME} where a=6" $DBNAME # RVBT_DELETE_OBJECT_PHYSICAL

cubrid server start $DBNAME

csql -udba -c "insert into ${TBNAME}2 (a) values(3)" $DBNAME # RVHF_MVCC_INSERT
csql -udba -c "insert into ${TBNAME}2 (a) values(5)" $DBNAME 
csql -udba -c "update ${TBNAME}2 set a=4 where a=3" $DBNAME # RVHF_UPDATE_NOTIFY_VACUUM

csql -udba -c "insert into ${TBNAME}_big (a) values('a')" $DBNAME 
csql -udba -c "update ${TBNAME}_big set a='b' where a='a'" $DBNAME # RVHF_MVCC_UPDATE_OVERFLOW

csql -udba --no-auto-commit -c "delete ${TBNAME}_part where a=25;\
  alter table ${TBNAME}_part reorganize partition less_29 into\
  (partition less_20 values less than (20), partition less_30 values less than (30));
  commit;" $DBNAME # RVHF_MVCC_REDISTRIBUTE

csql -udba -c "create index idx_a on ${TBNAME}2 (a)" $DBNAME
csql -udba -c "insert into ${TBNAME}2 (a) values(6)" $DBNAME # RVBT_MVCC_INSERT_OBJECT

csql -udba -c "create index idx_big on ${TBNAME}2_big (a)" $DBNAME
csql -udba -c "insert into ${TBNAME}2_big (a) values(' ')" $DBNAME # RVBT_RECORD_MODIFY_UNDOREDO

csql -udba --no-auto-commit -c "\
  insert ${TBNAME}_uni (a) values(-1);\
  delete ${TBNAME}_uni where a=-1;\
  insert ${TBNAME}_uni (a) values(-1);rollback;\
  " $DBNAME # RVBT_MVCC_INSERT_OBJECT_UNQ, RVBT_RECORD_MODIFY_COMPENSATE

cubrid server stop $DBNAME

cat csql.err | grep "prior_set_tde_encrypted";
cat $DB_SERVERLOG | grep "prior_set_tde_encrypted";
# EXPECTED:
# must be able to see RVHF_MVCC_REDISTRIBUTE, RVHF_INSERT,RVHF_UPDATE, RVHF_DELETE, RVHF_INSERT_NEWHOME, RVOVF_NEWPAGE_INSERT, RVHF_PAGE_UPDATE, RVBT_COPYPAGE, RVBT_NON_MVCC_INSERT_OBJECT, RVBT_DELETE_OBJECT_PHYSICAL, RVHF_MVCC_INSERT, RVHF_UPDATE_NOTIFY_VACUUM, RVHF_MVCC_UPDATE_OVERFLOW, RVBT_MVCC_INSERT_OBJECT, RVBT_RECORD_MODIFY_UNDOREDO, RVBT_MVCC_INSERT_OBJECT_UNQ, RVBT_RECORD_MODIFY_COMPENSATE in prior_set_tde_encrypted(): rcvindex = XXX

cubrid server stop $DBNAME
cubrid deletedb $DBNAME
