DBNAME=$1

if [ -z $DBNAME ]; then
  echo "Usage: clear.sh {db_name}"
  exit 1
fi

for RECNUM in 10000 100000 1000000 10000000
do
  _DBNAME=${DBNAME}_${RECNUM}
  cubrid deletedb $_DBNAME
  rm -rf $_DBNAME
done
