#!/bin/bash

cubrid createdb --db-volume-size=128M --log-volume-size=128M $DBNAME ko_KR.utf8

cubrid server start ${DBNAME}

csql -udba -c "create table b (b int primary key);" ${DBNAME}
csql -udba -c "create table a (a int, z int auto_increment, y int, constraint fk_y foreign key (y) references b(b)) encrypt;" ${DBNAME}
csql -udba -c "create table c (a int primary key) encrypt;" ${DBNAME}
csql -udba -c "create table d (a int, index ia (a)) encrypt;" ${DBNAME}
csql -udba -c "create table e (a int, constraint pk_a_a primary key (a)) encrypt;" ${DBNAME}

cubrid server stop ${DBNAME}

rm ${DBNAME}_keys

cubrid server start ${DBNAME}
# EXPECTED: success to start

set -x 
csql -udba -c "alter table a add b int;" ${DBNAME}
csql -udba -c "alter table a rename a as b;" ${DBNAME}
csql -udba -c "alter table a modify a bigint;" ${DBNAME}
csql -udba -c "alter table a change a b int;" ${DBNAME}
csql -udba -c "alter table a drop column a;" ${DBNAME}

csql -udba -c "alter table a alter column a set default 0;" ${DBNAME}

csql -udba -c "alter table a comment='new comment'" ${DBNAME}

csql -udba -c "alter table a add constraint pk_a_a primary key(a);" ${DBNAME}
csql -udba -c "alter table e drop constraint pk_a_a;" ${DBNAME}
csql -udba -c "alter table a add constraint ua unique(a);" ${DBNAME}
csql -udba -c "alter table a drop foreign key fk_y;" ${DBNAME}

csql -udba -c "alter table c drop primary key;" ${DBNAME}
csql -udba -c "alter table a add index ia(a ASC);" ${DBNAME}
csql -udba -c "rename table a as ra;" ${DBNAME}
# EXPECTED: All the statements above fail (TDE Module is not loaded)

csql -udba -c "alter table d drop index ia;" ${DBNAME}
# EXPECTED: fails, Your transaction has been aborted by the system??? committed what?

csql -udba -c "alter table a auto_increment=5;" ${DBNAME}
csql -udba -c "select class_name, current_val from db_serial where class_name='a';" ${DBNAME}
# EXPECTED: success and you can see the changed value from db_serial

csql -udba -c "show create table a;" ${DBNAME}
csql -udba -c "show create table b;" ${DBNAME}
csql -udba -c "show create table c;" ${DBNAME}
csql -udba -c "show create table d;" ${DBNAME}
csql -udba -c "show create table e;" ${DBNAME}
# EXPECTED: nothing has been changed.

cubrid server stop ${DBNAME}
cubrid deletedb $DBNAME
