#set -e

DBNAME=$1
HAS_PK=$2

TBNAME=t1

if [ -z $DBNAME ]; then
  echo "Usage: populate.sh {db_name}"
  exit 1
fi

if [ ! -f Insert.java ]; then
  echo "There is no Insert.java"
  exit 1
fi

if [ -z $HAS_PK ]; then
  echo "Without an index"
  HAS_PK=0
else
  HAS_PK=1
fi

# prepare environments

javac Insert.java

cubrid --version

set +e
cubrid broker start
#set -e

# start
DATASIZE=10000000000 # 100 * 100M = 10G
for RECSIZE in 10 100 1000 10000
do
  EXTRA_SIZE=12
  RECNUM=$(( ${DATASIZE} / (${RECSIZE} + ${EXTRA_SIZE}) ))
  _DBNAME=${DBNAME}_D10G_`numfmt --to si --format "%f" ${RECSIZE}`
  echo "Populating ${_DBNAME}"
  mkdir $_DBNAME
  
  cd $_DBNAME
  cubrid createdb $_DBNAME en_US
  
  cubrid server start $_DBNAME

  if [ "$HAS_PK" = "0" ]; then
    csql -udba -c "create table ${TBNAME} (a char(${RECSIZE}))" $_DBNAME
  else
    csql -udba -c "create table ${TBNAME} (a char(${RECSIZE}) primary key)" $_DBNAME
  fi
  
  java -cp $CUBRID/jdbc/cubrid_jdbc.jar:.. Insert $_DBNAME t1 33000 $RECSIZE $RECNUM

  cubrid backupdb -S $_DBNAME
  cubrid diagdb -d3 $_DBNAME > diag.d3 
  
  cubrid server stop $_DBNAME
  cd ..
done

