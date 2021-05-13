create table tbl (a int primary key);
insert into tbl values (3), (4);
update statistics on tbl;
;info stats tbl
truncate tbl;
insert into tbl values (1); -- without this, it is considered doubtful statistic (0 objects)
update statistics on tbl;
;info stats tbl -- total object = 1 
