;auto off
truncate tbl;
insert into tbl values (1);
truncate tbl;
insert into tbl values (2);
rollback;
truncate tbl;
insert into tbl values (3);
truncate tbl;
insert into tbl values (4);
truncate tbl;
insert into tbl values (5);
rollback;
