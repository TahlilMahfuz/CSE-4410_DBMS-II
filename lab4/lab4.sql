drop table AccountProperty;
drop table Account;
drop table transaction;
drop table balance;

create table AccountProperty(
ID int primary key ,
name varchar(20),
ProfitRate numeric(10,2),
GracePeriod int
);

create table account(
ID int primary key,
name varchar(50),
AccCode int,
openingDate timestamp,
lastDateInterest timestamp,
foreign key (AccCode) references AccountProperty(ID)
);

create table transaction(
TID int primary key,
AccNo int,
Amount numeric(10,2),
transactionDate timestamp,
constraint fk_transaction foreign key (AccNo) references account(ID)
);


create table balance(
AccNo int primary key ,
PrincipleAmount numeric(10,4),
ProfitAmount numeric(10,4),
foreign key (AccNo) references account(ID)
);

insert into accountProperty values(2002,'monthly',2.2,1);
insert into accountProperty values(3003,'quarterly',4.2,4);
insert into accountProperty values(4004,'biyearly',6.8,6);
insert into accountProperty values(5005,'yearly',8,12);

insert into account values(1,'tahlil',2002,sysdate-10212,sysdate-123142);
insert into account values(2,'tahlil',3003,sysdate-123124,sysdate-41241);
insert into account values(3,'tahlil',4004,sysdate-10000,sysdate-900);
insert into account values(4,'tahlil',5005,sysdate-12312,sysdate-10);

insert into transaction values(1,1,1000,sysdate-100000);
insert into transaction values(2,2,1000,sysdate-100020);
insert into transaction values(3,3,1000,sysdate-100040);
insert into transaction values(4,4,1000,sysdate-100210);
insert into transaction values(6,1,2000,sysdate-2314);

insert into balance values(1,100,10);
insert into balance values(2,100,10);
insert into balance values(3,100,10);
insert into balance values(4,100,10);

select * from AccountProperty;
select * from Account;
select * from balance;
select * from transaction;


set serverout on;

-- A --
create or replace function
curr_balance (accountid int)
return numeric
As
    curr transaction.AMOUNT%type;
    principle balance.PrincipleAmount%type;
begin
    select sum(Amount) into curr
    from account natural join transaction
    where AccNo=accountid;

    select PrincipleAmount into principle
    from balance
    where AccNo=accountid;

    curr:=curr+principle;

    return curr;
end;


-- B --
create or replace
type profit_tracking as object
(
    profit numeric(6,2),
    balance_bef_profit numeric(6,2),
    balance_after_profit numeric(6,2)
);

create or replace function
calculateProfit(accountid int)
return profit_tracking
is
    data profit_tracking;
    prof numeric;
    Bal_bef_profit numeric;
    Bal_after_prof numeric;
    grace_period int;
    openingdt date;
    balance numeric;
    prebalance numeric;
    profrate numeric;
    duration number;
    c int default 0;
    preprofit numeric;
begin
    Bal_bef_profit:=curr_balance(accountid);
    balance:=Bal_bef_profit;
    prebalance:=Bal_bef_profit;
    prof:=0;
    select GracePeriod,openingDate,ProfitRate into grace_period,openingdt,profrate
    from account,AccountProperty
    where account.ID=accountid and AccCode=AccountProperty.ID;

    duration:=sysdate-openingdt;

    loop
        if(duration>0) then
            if c=grace_period then
                prebalance:=prebalance+preprofit;
                c:=0;
                preprofit:=0;
            end if;
            prof:=prof+prebalance*(profrate/100);
            preprofit:=preprofit+prof;
            duration:=duration-30;
            c:=c+1;
        else
            exit;
        end if;
    end loop;

    prof:=prebalance-Bal_bef_profit;
    Bal_after_prof:=balance;

    data:=profit_tracking(prof,Bal_bef_profit,Bal_after_prof);

    return data;

end;

-- C --
create or replace procedure
tot_profit
as
    type amount is record(profit numeric);
    profit_table amount;

    data profit_tracking;
    cnt number default 0;
    total_profit numeric;

    cursor c is
        select unique id,openingDate
        from account;
begin
    for row in c loop
        data:=calculateProfit(row.ID);
        cnt:=cnt+1;
        total_profit:=total_profit+data.PROFIT;
    end loop;
    profit_table.profit:=total_profit;
    DBMS_OUTPUT.PUT_LINE(total_profit);
end;
















