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

sudo bash -c "sync; echo 1 > /proc/sys/vm/drop_caches"
# exp1
echo "================================================================"
echo "=============================exp1===============================" >> $EXP_RESULT
echo "================================================================"
for RECNUM in 100000 1000000 10000000 100000000
do
  _DBNAME=${DBNAME}_`numfmt --to si --format "%f" ${RECNUM}`
  
  # exp1
  ./exp1.sh $_DBNAME $TRYCNT >> $EXP_RESULT
done

sudo bash -c "sync; echo 1 > /proc/sys/vm/drop_caches"
# exp2
echo "================================================================"
echo "=============================exp2===============================" >> $EXP_RESULT
echo "================================================================"
_DBNAME=${DBNAME}_`numfmt --to si --format "%f" 100000000`
# ./exp2.sh $_DBNAME $TRYCNT >> $EXP_RESULT 
echo "we can see it from exp1 with #records of 100M" >> $EXP_RESULT

sudo bash -c "sync; echo 1 > /proc/sys/vm/drop_caches"
# exp3
echo "================================================================"
echo "=============================exp3===============================" >> $EXP_RESULT
echo "================================================================"
DATASIZE=10000000000 # 100 * 100M = 10G
for RECSIZE in 10 100 1000 10000
do
  # RECNUM=$( expr ${DATASIZE} / ${RECSIZE} )
  _DBNAME=exp3_D10G_`numfmt --to si --format "%f" ${RECSIZE}`
  ./exp_wc.sh $_DBNAME $TRYCNT >> $EXP_RESULT
done

sudo bash -c "sync; echo 1 > /proc/sys/vm/drop_caches"
# exp4
echo "================================================================"
echo "=============================exp4===============================" >> $EXP_RESULT
echo "================================================================"
_DBNAME=${DBNAME}_PK_100M
# ./exp_wc.sh $_DBNAME $TRYCNT >> $EXP_RESULT
echo "we can see it from exp5" >> $EXP_RESULT

sudo bash -c "sync; echo 1 > /proc/sys/vm/drop_caches"
# exp5
echo "================================================================"
echo "=============================exp5===============================" >> $EXP_RESULT
echo "================================================================"
_DBNAME=${DBNAME}_PK_100M
./exp5.sh $_DBNAME $TRYCNT >> $EXP_RESULT

sudo bash -c "sync; echo 1 > /proc/sys/vm/drop_caches"
# exp6
echo "================================================================"
echo "=============================exp6===============================" >> $EXP_RESULT
echo "================================================================"
_DBNAME=${DBNAME}_PK_FK_100M
./exp_wc.sh $_DBNAME $TRYCNT >> $EXP_RESULT

sudo bash -c "sync; echo 1 > /proc/sys/vm/drop_caches"
# exp8-1
echo "================================================================"
echo "=============================exp8-1=============================" >> $EXP_RESULT
echo "================================================================"
#for CAT_RECNUM in 1000 100000 10000000 # 1K 100K 1M
#do
#  _DBNAME=${DBNAME}_DR_100M_`numfmt --to si --format "%f" ${CAT_RECNUM}`
#  
#  ./exp_wc.sh $_DBNAME $TRYCNT >> $EXP_RESULT
#done
echo "Pended until an index on _db_domain is created"

sudo bash -c "sync; echo 1 > /proc/sys/vm/drop_caches"
# exp8-2
echo "================================================================"
echo "=============================exp8-2=============================" >> $EXP_RESULT
echo "================================================================"
_DBNAME=${DBNAME}_PK_IH_100M # Inheritance
./exp_wc.sh $_DBNAME $TRYCNT >> $EXP_RESULT

echo "========= SUCCESS ==========="
echo "========= result: ${EXP_RESULT} ==========="
