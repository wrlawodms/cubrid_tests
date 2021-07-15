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
  WARMUP="1"
fi

if [ -z $COMMIT ]; then
  COMMIT="1"
fi

echo "DB_NAME=$DBNAME TB_NAME=$TBNAME warm-up=$WARMUP commit=$COMMIT"

cubrid --version

cp cubrid.conf $CUBRID/conf/cubrid.conf

echo "------------- buffers in cubrid.conf ------------"
cubrid paramdump -S tdb10M | grep -e "buffer"
echo "-------------------------------------------------"

set -x
cubrid server start $DBNAME

# 0. wait for db to get stable
sleep 30

# 1. warm-up
if [ "$WARMUP" -ne "0" ]; then
  csql -udba -c "select count(*) from t1" $DBNAME;
fi

# 2. truncate
if [ "$COMMIT" -ne "0" ]; then
  csql -udba -i truncate_commit.sql $DBNAME
else
  csql -udba -i truncate_nocommit.sql $DBNAME
fi

csql -udba -c "select count(*) from t1" $DBNAME;

cubrid server stop $DBNAME
