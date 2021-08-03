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

# exp2
_DBNAME=${DBNAME}_`numfmt --to si --format "%f" 100000000`
./exp2.sh $_DBNAME $TRYCNT >> $EXP_RESULT

# exp3
DATASIZE=10000000000 # 100 * 100M = 10G
for RECSIZE in 10 100 1000 10000
do
  RECNUM=$( expr ${DATASIZE} / ${RECSIZE} )
  _DBNAME=${DBNAME}_10G_`numfmt --to si --format "%f" ${RECSIZE}`
  ./exp_w_c.sh $_DBNAME $TRYCNT >> $EXP_RESULT
done

# exp4
_DBNAME=${DBNAME}_100M_PK
./exp_w_c.sh $_DBNAME $TRYCNT >> $EXP_RESULT

# exp5
# see the #log_volumes, vacuum stat above 
# _DBNAME=${DBNAME}_100M_PK
# ./exp_w_c.sh $_DBNAME $TRYCNT >> $EXP_RESULT

# exp6
_DBNAME=${DBNAME}_100M_PK_FK
./exp_w_c.sh $_DBNAME $TRYCNT >> $EXP_RESULT

# exp8-1
_DBNAME=${DBNAME}_100M_DR # DONT_REUSE_OID
./exp_w_c.sh $_DBNAME $TRYCNT >> $EXP_RESULT

# exp8-2
_DBNAME=${DBNAME}_100M_PK_IH # Inheritance
./exp_w_c.sh $_DBNAME $TRYCNT >> $EXP_RESULT

echo "========= SUCCESS ==========="
echo "========= result: ${EXP_RESULT} ==========="
