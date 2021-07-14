set -e

DBNAME=$1
WARMUP=$2
COMMIT=$3

TBNAME=t1

USAGE="truncate.sh {DB_NAME} [warm-up=1] [commit=1]"

if [ ! -d $DBNAME ]; then
  echo $USAGE
  exit 1
fi

if [ -z $WARMUP ]; then
  WARMUP=1
else
  WARMUP=0
fi

if [ -z $COMMIT ]; then
  COMMIT=1
else
  COMMIT=0
fi

echo "DB_NAME=$DBNAME TB_NAME=$TBNAME warm-up=$WARMUP commit=$COMMIT"

cubrid --version

set -x
cubrid server start $DBNAME

# 1. warm-up
if [ $WARMUP != 0 ]; then
  csql -udba -c "select count(*) from t1" $DBNAME;
fi

# 2. truncate
if [ $COMMIT != 0 ]; then
  csql -udba -i truncate_nocommit.sql $DBNAME
else
  csql -udba -i truncate_commit.sql $DBNAME
fi

cubrid server stop $DBNAME
