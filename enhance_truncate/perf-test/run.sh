set -e

DBNAME=$1
TRYCNT=$2
if [ -z $DBNAME ]; then
  echo "Usage: run.sh {db_name} [try_cnt=1]"
  exit 1
fi

if [ -z $TRYCNT ]; then
  TRYCNT="1"
fi

DATE=`date "+%Y%m%d-%H%M%S"`
RESULTS_DIR="results"
EXP_RESULT="${RESULTS_DIR}/exp_${DATE}.result"
touch $EXP_RESULT 

# exp1
for RECNUM in 100000 1000000 10000000 100000000
do
  _DBNAME=${DBNAME}_`numfmt --to si --format "%f" ${RECNUM}`
  
  # exp1
  ./exp1.sh $_DBNAME $TRYCNT >> $EXP_RESULT
done

# exp2 10M
_DBNAME=${DBNAME}_`numfmt --to si --format "%f" 100000000`
./exp2.sh $_DBNAME $TRYCNT >> $EXP_RESULT

echo "========= SUCCESS ==========="
echo "========= result: ${EXP_RESULT} ==========="
