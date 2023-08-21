drop table franchise;
drop table registers;
drop table customers;

create table franchises
(fid int primary key,
fname varchar2(20)
);

create table customers
(cid int primary key,
cname varchar2(20)
);

create table registers
(cid int,
fid int,
CONSTRAINT fk_cus foreign key (cid) references customers(cid),
CONSTRAINT fk_frans foreign key (fid) references franchises(fid)
);

create table branches
(bid int primary key,
fid int,
bname varchar2(20),
constraint fk_br foreign key (fid) references franchises(fid)
);

create table chefs
(chefid int primary key,
bid int,
chefname varchar2(20),
constraint fk_chef foreign key (bid) references branches(bid)
);

create table cuisine
(cuisineid int primary key,
chefid int,
orderid int,
cuisinename varchar2(20),
constraint fk_cuisine foreign key (chefid) references chefs(chefid),
constraint fk_order foreign key (orderid) references orderlist(orderid)
);

create table menu
(fid int,
cuisineid int,
constraint fk_menucu foreign key (cuisineid) references cuisine(cuisineid),
constraint fk_menufr foreign key (fid) references franchises(fid)
);

create table orderlist
(orderid int primary key,
cid int,
CONSTRAINT fk_cus_or foreign key (cid) references customers(cid)
);

alter table orderlist add rating real;
alter table cuisine add price real;
alter table cuisine add calorycount real;

--solution
--a
select fname,count(cid) as numberofcustomers
from franchises natural join customers natural join registers
group by fname,fid; 
--b
select cuisineid,cuisinename,avg(rating)
from cuisine natural join orderlist
group by cuisineid,cuisinename;
--c
select cuisineid,cuisinename,count(cuisineid) as numofcuisine
from cuisine natural join orderlist
where rownum<=5
group by cuisineid,cuisinename
order by count(cuisineid)
;
--d
select *
from (select cid,cname,count(fid) as tot_franchises
        from orderlist natural join customers natural join registers natural join franchises
        group by cid,cname)
where tot_franchises>2;
--e
select cid,cname  
from (select cid
        from customers
        minus 
        select cid
        from orderlist) t natural join customers
;



insert into customers(cid,cname) values('1','Tahlil');
insert into customers(cid,cname) values('2','Mahfuz');
insert into customers(cid,cname) values('3','Faruk');
insert into customers(cid,cname) values('4','Faiyaz');
insert into customers(cid,cname) values('5','Namzul');

insert into franchises(fid,fname) values('1','kfc');
insert into franchises(fid,fname) values('2','burgerking');
insert into franchises(fid,fname) values('3','dominos');
insert into franchises(fid,fname) values('4','sultansdine');
insert into franchises(fid,fname) values('5','taichi');

insert into registers(fid,cid) values('1','4');
insert into registers(fid,cid) values('2','4');
insert into registers(fid,cid) values('2','2');
insert into registers(fid,cid) values('4','1');
insert into registers(fid,cid) values('4','2');


select * from franchises order by fid;
select * from customers order by cid;
select * from registers;