-- A --
CREATE SEQUENCE Serial_seq
MINVALUE 10001
MAXVALUE 99999
START WITH 10001
INCREMENT BY 1
CACHE 20;

create or replace function
generate_accID(name ACCOUNT.NAME%type,acc_code ACCOUNT.ACCCODE%type,opendt ACCOUNT.OPENINGDATE%type)
return varchar
as
    accid varchar(100);
    new_id int;
begin
    SELECT Serial_seq . NEXTVAL INTO NEW_ID
    FROM DUAL ;

    accid:= acc_code||trim(both '/' from to_char(opendt,'yyyy/mm/dd'))||'.'||substr(name,1,3)||'.'||new_id;

    return accid;
end;

--B--
-- drop table balance;
-- drop table transaction;
-- drop table Account;
-- drop table AccountProperty;
--
-- create table AccountProperty(
-- ID int primary key ,
-- name varchar(20),
-- ProfitRate numeric(10,2),
-- GracePeriod int
-- );
--
-- create table account(
-- id varchar(20) primary key,
-- name varchar(50),
-- AccCode int,
-- openingDate timestamp,
-- lastDateInterest timestamp,
-- foreign key (AccCode) references AccountProperty(ID)
-- );
--
-- create table transaction(
-- TID int primary key,
-- AccNo varchar(20),
-- Amount numeric(10,2),
-- transactionDate timestamp,
-- constraint fk_transaction foreign key (AccNo) references account(ID)
-- );
-- --
--
-- create table balance(
-- AccNo varchar(20) primary key ,
-- PrincipleAmount numeric(10,4),
-- ProfitAmount numeric(10,4),
-- foreign key (AccNo) references account(ID)
-- );


alter table account
add column id cascade constraints;

alter table transaction
drop column accno cascade constraints;

alter table balance
drop column accno cascade constraints;

alter table account
add id varchar(20) primary key;

alter table transaction
add accno varchar(20);

alter table transaction
add constraint fk_transaction foreign key (AccNo) references account(ID);

alter table balance
add accno varchar(20) primary key;

alter table balance
add constraint fk_account foreign key (AccNo) references account(ID);

--C--
CREATE OR REPLACE
TRIGGER Account_ID_generator
BEFORE INSERT ON account
FOR EACH ROW
declare
    data account.id%type;
BEGIN
    data:=GENERATE_ACCID(:new.name,:new.AccCode,:new.openingDate);
    :new.id:=data;
END ;

-- D --
CREATE OR REPLACE
TRIGGER balance_entry
after INSERT ON account
FOR EACH ROW
BEGIN
    insert into balance values(5000,0,:new.id);
END ;

-- E --
CREATE OR REPLACE
TRIGGER update_principleamount
after INSERT ON TRANSACTION
FOR EACH ROW
declare
    amount TRANSACTION.AMOUNT%type;
    id ACCOUNT.id%type;
BEGIN
    id:=:new.accno;
    amount:=:new.AMOUNT;

    update balance
    set PRINCIPLEAMOUNT=PRINCIPLEAMOUNT+AMOUNT
    where BALANCE.accno=id;

END ;






























