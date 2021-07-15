#!/usr/bin/bash
set -e

DBNAME=$1
BKVOLUME=${DBNAME}_bk0v000

USAGE="truncate.sh {DB_NAME}"

if [ ! -d $DBNAME ]; then
  echo $USAGE
  exit 1
fi

cd $DBNAME

if [ -f $BKVOLUME ]; then
  echo "Restore with ${BKVOLUME}"
else
  echo "Can't find ${BKVOLUME}"
fi

set +e
rm $DBNAME
rm ${DBNAME}_lg*
set -e
cubrid restoredb -d backuptime $DBNAME
