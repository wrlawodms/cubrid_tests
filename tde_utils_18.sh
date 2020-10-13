#!/bin/bash

TBNAME=test_tbl

rm -rf $DBNAME
mkdir $DBNAME
cd $DBNAME

cubrid deletedb $DBNAME

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

csql -udba -S -c "create table $TBNAME (a int) encrypt" $DBNAME
csql -udba -S -c "insert into $TBNAME (a) values(3)" $DBNAME

mkdir keys
cp ${DBNAME}_keys keys/
cp ${DBNAME}_keys ${DBNAME}_tmp_keys

set -x 

cubrid tde -n $DBNAME # 2
cubrid backupdb -S $DBNAME

cubrid tde -n $DBNAME # 3
cubrid backupdb -S -l1 $DBNAME

rm ${DBNAME}_keys

# Priority:
# 1) The key file given as the option, -k
# 2) The key file in the backup volume
#     - If it is an incremental backup, the key file of highest volume is used
# 3) The backup key file out of the backup volume (_bk{level}_keys)
# 4) the key file set in the cubrid.conf (tde_keys_file_path)
# 5) the key file on the deafult path ({database_name}_keys)

# Note 1: The number of keys in the key file is used to identify the key file
# Note 2: After restoredb, if the default key file doesn't have the proper key to decrypt database, the key file used for restoredb become the default key file, otherwise the default key file is kept.

cubrid restoredb -k ${DBNAME}_tmp_keys $DBNAME # 1.1) check if _tmp_keys are used even though a key file is included in backup file
cubrid tde -s $DBNAME   # must have one key

rm ${DBNAME}_keys
cubrid restoredb $DBNAME # 2.1) check if the restored key file in the level 0 backup volume is used. (_bk0_keys)
cubrid tde -s $DBNAME   # must have two keys

rm ${DBNAME}_keys
cubrid restoredb -l1 $DBNAME # 2.2) check if the restored key file is used. (_bk1_keys)
cubrid tde -s $DBNAME   # must have three keys

rm *bk*

cubrid tde -n $DBNAME # 4

cubrid backupdb -S -k $DBNAME # do not include key file in the backup volume

rm ${DBNAME}_keys
cubrid restoredb -k ${DBNAME}_tmp_keys $DBNAME # 1.2) check if _tmp_keys are used
cubrid tde -s $DBNAME # must have one key

rm ${DBNAME}_keys
cubrid restoredb $DBNAME # 3) check if separated key is used. (_bk0_keys)
cubrid tde -s $DBNAME # must have four keys

rm ${DBNAME}_bk0_keys

echo "tde_keys_file_path=keys" >> $DBCONF

cubrid restoredb $DBNAME # 4) check if key set on config is used (_tmp_keys.copy)
cubrid tde -s $DBNAME # must have one key

echo "tde_keys_file_path=" >> $DBCONF

cubrid restoredb $DBNAME # 5) check if the normal key is used (_keys)
cubrid tde -s $DBNAME # must have four keys

cubrid deletedb $DBNAME
