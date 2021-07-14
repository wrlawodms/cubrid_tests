set -e

DBNAME=$1
TRYCNT=$2

if [ -z $DBNAME ]; then
  echo "Usage: exp1.sh {db_name} [try_cnt=1]"
  exit 1
fi

if [ -z $TRYCNT ]; then
  TRYCNT="1"
fi

source ~/.cubrid.tt.release.sh
echo "========= tt ==========="
echo "CUBRID=$CUBRID"

for i in $(seq "$TRYCNT")
do
  echo "========= exp1.sh tt try = $i ==============="
  # 1. truncate
  ./truncate.sh $DBNAME
  # 2. restore
  ./restore.sh $DBNAME
done

source ~/.cubrid.develop.release.sh
echo "========= dev ==========="
echo "CUBRID=$CUBRID"

for i in $(seq "$TRYCNT")
do
  echo "========= exp1.sh develop try = $i ==============="
  # 1. truncate
  ./truncate.sh $DBNAME
  # 2. restore
  ./restore.sh $DBNAME
done
