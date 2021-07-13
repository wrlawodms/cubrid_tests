#set -e

DBNAME=$1
HAS_PK=$2

RECSIZE=100
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
for RECNUM in 10000 100000 1000000 10000000
do
  _DBNAME=${DBNAME}_`numfmt --to si --format "%f" ${RECNUM}`
  echo "Populating ${_DBNAME}"
  mkdir $_DBNAME
  
  cd $_DBNAME
  cubrid createdb $_DBNAME en_US
  cd ..
  
  cubrid server start $_DBNAME

  if [ "$HAS_PK" = "0" ]; then
    csql -udba -c "create table ${TBNAME} (a char(${RECSIZE}))" $_DBNAME
  else
    csql -udba -c "create table ${TBNAME} (a char(${RECSIZE}) primary key)" $_DBNAME
  fi
  
  java -cp $CUBRID/jdbc/cubrid_jdbc.jar:. Insert $_DBNAME t1 33000 $RECSIZE $RECNUM
  
  cubrid server stop $_DBNAME
  
done

