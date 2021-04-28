create table parent (a int);
insert into parent values(3);
truncate parent;
select count(*) from parent;
drop parent;

create table parent (a int primary key);
insert into parent values(3);
truncate parent;
select count(*) from parent;
drop parent;

create table parent (a int);
insert into parent values(3);
truncate parent cascade;
select count(*) from parent;
drop parent;

create table parent (a int primary key);
insert into parent values(3);
truncate parent cascade;
select count(*) from parent;
drop parent;

