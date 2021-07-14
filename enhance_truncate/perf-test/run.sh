set -e

DBNAME=$1
if [ -z $DBNAME ]; then
  echo "Usage: run.sh {db_name}"
  exit 1
fi

DATE=`date "+%Y%m%d-%H%M%S"`
RESULTS_DIR="results"
EXP1_RESULT="${RESULTS_DIR}/exp1_${DATE}.result"
touch $EXP1_RESULT 

for RECNUM in 100000 1000000 #10000000 #100000000
do
  _DBNAME=${DBNAME}_`numfmt --to si --format "%f" ${RECNUM}`

  # exp1
  ./exp1.sh $_DBNAME >> $EXP1_RESULT
done

echo "========= SUCCESS ==========="
echo "========= result: ${EXP1_RESULT} ==========="
