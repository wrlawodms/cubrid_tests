#!/usr/bin/bash
set -x

DBNAME=$1
BKVOLUME=${DBNAME}_bk0v000

if [ -f $BKVOLUME ]; then
  echo "Restore with ${BKVOLUME}"
else
  echo "Can't find ${BKVOLUME}"
fi

rm $DBNAME
rm ${DBNAME}_lg*
cubrid restoredb -d backuptime $DBNAME

