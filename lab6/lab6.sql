drop table logBook;
drop table RegSims;
drop table PLANS;
drop table CUSTOMER;

drop table transaction;
drop table misconducts;
drop table student;

create table Customer
(
    CID     varchar(20) primary key,
    name    varchar(20),
    DOB     timestamp,
    Address varchar(30),
    time timestamp
);

create table plans
(
    PID            int primary key,
    name           varchar(20),
    charge_per_min number
);

create table RegSims
(
    SID int primary key,
    CID varchar(20),
    PID int,
    MobNumber varchar(20) unique,
    constraint fk_regsim_customer foreign key (CID) references Customer(CID),
    constraint fk_regsim_plan foreign key (PID) references plans(PID)
);

create table logBook
(
    Call_id int,
    SID     int,
    begin   date,
    end     date,
    charge  number,
    constraint fk_logBook foreign key (SID) references RegSims(SID)
);



create or replace function
Cal_charge (simNum int, b date, e date)
return number
As
    charge plans.charge_per_min%type;
    duration number;
    rduration number;
begin
    select charge_per_min into charge
    from RegSims natural join plans
    where SID=simNum;
    duration:=(e-b)*24*60;
    rduration:=round(duration);

    if duration > rduration then
        duration:=round(duration)+1;
    end if;

    charge:=charge*duration;

    return charge;
end;


create or replace function
Generate_ID
return varchar
As
    maxID varchar(20);
    maxtime date;
    editdate varchar(20);
    editnum varchar(20);
begin
    select CID,time into maxID,maxtime
        from CUSTOMER
        where ROWNUM<=1
        order by time desc;
    editdate:=TO_CHAR(sysdate, 'yyyymmdd');
    if(maxID = null) then
        return editdate||'.00000001';
    end if;

    editnum:=to_number(substr(maxid,10,8))+1;

    return editdate||'.'||to_char(LPAD(to_char(editnum),8,'0'));


end;


CREATE OR REPLACE
TRIGGER new_CID
before INSERT ON Customer
FOR EACH ROW
declare
    new_id CUSTOMER.CID%type;
BEGIN
    new_id:=Generate_ID();
    :new.CID:=new_id;
END ;



create table student
(
    ID   int primary key,
    name varchar(20),
    prog varchar(20),
    year varchar(20),
    cgpa number
);

create table misconducts
(
    id          int,
    time        date,
    description varchar(100),
    foreign key (id) references student(id)
);



create table transaction
(
    id   int,
    time date,
    amount_paid number,
    foreign key (id) references student (id)
);

create or replace procedure
do_transaction(id student.id%type,amount transaction.amount_paid%type)
As
begin
    insert into transaction values(id,sysdate,amount);
end;

create or replace function
Get_scholarship_Num(MsAmount number, SAmount number)
return varchar
As
    cnt number default 0;
    MAmount number;
    idcount number;
    cursor c is
        select ID
        from student
        where student.prog='4' and student.year='20' and cgpa>=3.5
        minus (select id from misconducts);
begin
    MAmount:=MsAmount;
    select count(id) into idcount
    from student
    where student.prog='4' and student.year='2' and cgpa>=3.5 --assuming that program code is 4 for swe
    minus
    (select id from misconducts);

    for rows in c loop
        do_transaction(rows.id,SAmount);
        MAmount:=MAmount-SAmount;
        cnt:=cnt+1;
        exit when MAmount<=0;
    end loop;

    return to_char(idcount-cnt) || to_char(cnt);

end;








