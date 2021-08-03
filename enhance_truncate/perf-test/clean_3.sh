DBNAME=$1

if [ -z $DBNAME ]; then
  echo "Usage: clear.sh {db_name}"
  exit 1
fi

DATASIZE=10000000000 # 100 * 100M
for RECSIZE in 10 100 1000 10000
do
  RECNUM=$( expr ${DATASIZE} / ${RECSIZE} )
  _DBNAME=${DBNAME}_100M_`numfmt --to si --format "%f" ${RECSIZE}`
  cubrid deletedb $_DBNAME
  rm -rf $_DBNAME
done
