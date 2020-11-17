#!/bin/bash

TBNAME=test_tbl

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

mkdir keys

# Cases:
# 1) The set key is in the server key file: 
#     - nothing happens
# 2) The set key is not in the server key file:
#     - backup key file is copied as a server key file
#     - the first key in the key file become the key set on the database
#   2.1) There is the server key file: move the file as _old
#     2.1.a) The server key file is by tde_keys_file_path sysparm: move the key by sysparm as _old
#   2.2) There is not the server key file: no additional thing
#   2.3) The first key index is not 0 case

echo "################################### (1) ###########################################"
cubrid backupdb -S $DBNAME
cubrid tde -n $DBNAME # 2
cubrid restoredb $DBNAME
cubrid tde -s $DBNAME # EXPECTED: must have two keys (not replaced)

rm *bk*
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

echo "################################### (2.1) ###########################################"
cubrid tde -n $DBNAME # 2
cubrid backupdb -S $DBNAME
cubrid tde -c 1 $DBNAME 
cubrid tde -d 0 $DBNAME # 1
cubrid restoredb -d backuptime $DBNAME 
cubrid tde -s $DBNAME # EXPECTED: the index of the set key has to be 0, and the key filemust have two keys (replaced with the backup key file)
ls # EXPECTED: must show _keys_old

rm *bk*
rm *_old
cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

echo "################################### (2.1.a) ###########################################"
cubrid tde -n $DBNAME # 2
cubrid backupdb -S $DBNAME
cubrid tde -c 1 $DBNAME 
cubrid tde -d 0 $DBNAME # 1
mv ${DBNAME}_keys keys
echo "tde_keys_file_path=keys" >> $DBCONF
cubrid restoredb -d backuptime $DBNAME 
cubrid tde -s $DBNAME # EXPECTED: the index of the set key has to be 0, and the key filemust have two keys (replaced with the backup key file)
ls # EXPECTED: must not show _keys_old
ls keys # EXPECTED: must show _keys_old

echo "tde_keys_file_path=" >> $DBCONF
rm *bk*
rm keys/*_old

cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

echo "################################### (2.2) ###########################################"
cubrid tde -n $DBNAME # 2
cubrid backupdb -S $DBNAME
rm ${DBNAME}_keys
cubrid restoredb -d backuptime $DBNAME 
cubrid tde -s $DBNAME # EXPECTED: the index of the set key has to be 0, and the key filemust have two keys (replaced with the backup key file)
ls # EXPECTED: must not show _keys_old

rm *bk*

cubrid deletedb $DBNAME
cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME en_US

echo "################################### (2.3) ###########################################"
cubrid tde -n $DBNAME # 2
cubrid tde -n $DBNAME # 3
cubrid tde -n $DBNAME # 4
cubrid tde -c 3 $DBNAME
cubrid tde -d 0 $DBNAME # 3 (1, 2, 3)
cubrid backupdb -S $DBNAME
rm ${DBNAME}_keys
cubrid restoredb -d backuptime $DBNAME 
cubrid tde -s $DBNAME # EXPECTED: the index of the set key has to be 1, and the key filemust have two keys (replaced with the backup key file)
ls # EXPECTED: must not show _keys_old

cubrid deletedb $DBNAME




