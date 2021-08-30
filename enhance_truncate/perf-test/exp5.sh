set -e

DBNAME=$1
TRYCNT=$2

if [ -z $DBNAME ]; then
  echo "Usage: exp5.sh {db_name} [try_cnt=1]"
  exit 1
fi

if [ -z $TRYCNT ]; then
  TRYCNT="1"
fi

echo ""
echo "******************* exp5 ********************"
echo ""

source ~/.cubrid.tt.release.sh
echo "========= tt ==========="
echo "CUBRID=$CUBRID"

for i in $(seq "$TRYCNT")
do
  echo "========= exp5.sh tt try = $i ==============="
  # 1. truncate warm-up commit
  ./truncate.sh $DBNAME 1 1

  rm $CUBRID/log/${DBNAME}_checkdb.err
  cubrid checkdb -S $DBNAME # to vacuum
  echo ""
  cat $CUBRID/log/${DBNAME}_checkdb.err | grep -B1 "Stand-alone vacuum execution"
  echo ""

  # 2. restore
  ./restore.sh $DBNAME
done

source ~/.cubrid.develop.release.sh
echo "========= dev ==========="
echo "CUBRID=$CUBRID"

for i in $(seq "$TRYCNT")
do
  echo "========= exp5.sh develop try = $i ==============="
  # 1. truncate warm-up commit
  ./truncate.sh $DBNAME 1 1

  rm $CUBRID/log/${DBNAME}_checkdb.err
  cubrid checkdb -S $DBNAME # to vacuum
  echo ""
  cat $CUBRID/log/${DBNAME}_checkdb.err | grep -B1 "Stand-alone vacuum execution"
  echo ""
  
  # 2. restore
  ./restore.sh $DBNAME
done
