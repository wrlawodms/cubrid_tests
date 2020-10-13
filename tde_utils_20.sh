#!/bin/bash

TBNAME=test_tbl

rm -rf $DBNAME
mkdir $DBNAME
cd $DBNAME

cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

mkdir keys

# Priority:
# 1) The key file includes the key set on the database.
# 2) The key file set on the database (_keys, tde_keys_file_path)
# 
# For example,
# the key set on the databse is in the _keys file, backup key file is ignored.
# However, it is only in the backup key file, the _keys file is replaced with it.
# In addition, if two key files don't have the key set on the database, restoredb select a random key in the key file (in _keys file if possible).

# Notes:
# - the server key file: the key file set on the database (_keys or tde_keys_file_path)
# - the backup key file: the key file in the backup volume or separated when backupdb
# - the set key: the key set on the database (can be seen by cubrid tde -s)
#
# Cases:
# A) There is the set key in any key file
# A-1) The set key is in the server key file: 
#     - nothing happens
# A-2) else, the set key is in the backup key file:  
#     - A-2-1-1) replace _keys file with the backup key file
#     - with tde_keys_file_path (A-2-1-2)
#     - A-2-2-1) (A-2-1), rename the original key file as _keys_old if it exists
#     - with tde_keys_file_path (A-2-2-2)
#
# B) There isn't the set key in any key file
# B-1) There is the server key file:
#     - B-1-1) Set the first key in the server key file for the database
#     - with tde_keys_file_path (B-1-2)
# B-2) There isn't the server key file:
#     - B-2-1) Set the first key in the backup key file for the database 
#       and copy the key file as _keys file (as the server key file)
#     - with tde_keys_file_path (B-2-2)

set -x

echo "################################### (A-1) ###########################################"
cubrid backupdb -S $DBNAME
cubrid tde -n $DBNAME # 2
cubrid restoredb $DBNAME
cubrid tde -s $DBNAME # must have two keys (not replaced)

rm *bk*
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

echo "################################### (A-2-1-1) ###########################################"
cubrid tde -n $DBNAME
cubrid backupdb -S $DBNAME
cubrid tde -c 1 $DBNAME
cubrid tde -d 0 $DBNAME # 1
cubrid restoredb -d backuptime $DBNAME 
cubrid tde -s $DBNAME # the index of the set key has to be 0, and the key file  must have two keys (replaced with the backup key file)
ls # must show _keys_old

echo "################################### (A-2-2-1) ###########################################"
rm ${DBNAME}_keys
rm ${DBNAME}_keys_old
cubrid restoredb -d backuptime $DBNAME 
cubrid tde -s $DBNAME # the index of the set key has to be 0, and the key file  must have two keys (replaced with the backup key file)
ls # must not show _keys_old

rm *bk*
cubrid deletedb $DBNAME
echo "tde_keys_file_path=keys" >> $DBCONF
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

echo "################################### (A-2-1-2) ###########################################"
cubrid tde -n $DBNAME
cubrid backupdb -S $DBNAME
cubrid tde -c 1 $DBNAME
cubrid tde -d 0 $DBNAME # 1
cubrid restoredb -d backuptime $DBNAME 
cubrid tde -s $DBNAME # the index of the set key has to be 0, and the key file  must have two keys (replaced with the backup key file)
ls keys # must show _keys_old

echo "################################### (A-2-2-2) ###########################################"
rm keys/${DBNAME}_keys
rm keys/${DBNAME}_keys_old
cubrid restoredb -d backuptime $DBNAME 
cubrid tde -s $DBNAME # the index of the set key has to be 0, and the key file  must have two keys (replaced with the backup key file)
ls keys # must not show _keys_old

echo "tde_keys_file_path=" >> $DBCONF
rm *bk*
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

# B) for this case, timed restoredb is used
echo "################################### (B-1-1) ###########################################"
cubrid backupdb -S $DBNAME # 0
cubrid tde -n $DBNAME # 1
cubrid tde -c 1 $DBNAME
RESTORE_DATE=`date "+%d-%m-%Y:%H:%M:%S"`
cubrid tde -n $DBNAME # 2
cubrid tde -n $DBNAME # 3
cubrid tde -c 3 $DBNAME
cubrid tde -d 0 $DBNAME
cubrid tde -d 1 $DBNAME
cubrid restoredb -d $RESTORE_DATE $DBNAME # but at the time to restore, the set key is 1, the backup key file has only 0, and the server key file has only 2, 3
cubrid tde -s $DBNAME # must have two keys (2, 3), and 2th key has to be set on the database

rm *bk*
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

echo "################################### (B-2-1) ###########################################"
cubrid tde -n $DBNAME # 1
cubrid tde -c 1 $DBNAME
cubrid backupdb -S $DBNAME # 0, 1
cubrid tde -n $DBNAME # 2
cubrid tde -c 2 $DBNAME
RESTORE_DATE=`date "+%d-%m-%Y:%H:%M:%S"`
cubrid tde -n $DBNAME # 3
cubrid tde -c 3 $DBNAME
cubrid tde -d 2 $DBNAME
rm ${DBNAME}_keys
cubrid restoredb -d $RESTORE_DATE $DBNAME # but at the time to restore, the set key is 2, the backup key file has only 0, 1, and the server key file has only 0, 1, 3 (and deleted)
cubrid tde -s $DBNAME # must have two keys (0, 1), and 0th key has to be set on the database

rm *bk*
cubrid deletedb $DBNAME
rm keys/*
echo "tde_keys_file_path=keys" >> $DBCONF
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

echo "################################### (B-1-2) ###########################################"
cubrid backupdb -S $DBNAME # 0
cubrid tde -n $DBNAME # 1
cubrid tde -c 1 $DBNAME
RESTORE_DATE=`date "+%d-%m-%Y:%H:%M:%S"`
cubrid tde -n $DBNAME # 2
cubrid tde -n $DBNAME # 3
cubrid tde -c 3 $DBNAME
cubrid tde -d 0 $DBNAME
cubrid tde -d 1 $DBNAME
cubrid restoredb -d $RESTORE_DATE $DBNAME # but at the time to restore, the set key is 1, the backup key file has only 0, and the server key file has only 2, 3
cubrid tde -s $DBNAME # must have two keys (2, 3), and 2th key has to be set on the database

rm *bk*
cubrid deletedb $DBNAME
rm keys/*
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

echo "################################### (B-2-2) ###########################################"
cubrid tde -n $DBNAME # 1
cubrid tde -c 1 $DBNAME
cubrid backupdb -S $DBNAME # 0, 1
cubrid tde -n $DBNAME # 2
cubrid tde -c 2 $DBNAME
RESTORE_DATE=`date "+%d-%m-%Y:%H:%M:%S"`
cubrid tde -n $DBNAME # 3
cubrid tde -c 3 $DBNAME
cubrid tde -d 2 $DBNAME
rm keys/${DBNAME}_keys
cubrid restoredb -d $RESTORE_DATE $DBNAME # but at the time to restore, the set key is 2, the backup key file has only 0, 1, and the server key file has only 0, 1, 3 (and deleted)
cubrid tde -s $DBNAME # must have two keys (0, 1), and 0th key has to be set on the database

cubrid deletedb $DBNAME
