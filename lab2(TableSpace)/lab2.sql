create tablespace tbs1
    datafile 'C:\SWE_STUDIES\Fourth_Semester\DBMS II LAB\lab2\tbs1.dbf' size 5m
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE;
    
create tablespace tbs2
    datafile 'C:\SWE_STUDIES\Fourth_Semester\DBMS II LAB\lab2\tbs2.dbf' size 5m
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE;
            
create user faiyaz identified by faiyaz default tablespace tbs1 quota 3m on tbs1;
alter user faiyaz quota 3m on tbs2;

grant dba to faiyaz;

conn faiyaz/faiyaz;

create table student
(id int primary key,
stdname varchar2(20),
deptid int,
constraint fk_std foreign key (deptid) references department(deptid)
)tablespace tbs1;

create table department
(deptid int primary key,
name varchar2(20)
)tablespace tbs1;

create table course
(code int primary key,
name varchar2(20),
credit real,
offerby int,
constraint fk_course foreign key (offerby) references department(deptid)
)tablespace tbs2;

SET SERVEROUTPUT ON SIZE 1000000;

BEGIN
FOR counter IN 1..1000000 LOOP
        INSERT INTO department (deptid,name) 
            VALUES (counter,'CSE');

END LOOP;
end;
/

BEGIN
FOR counter IN 1..1000000 LOOP
        INSERT INTO student (id,name,deptid) 
            VALUES (counter,'Tahlil',1);

END LOOP;
end;
/

BEGIN
FOR counter IN 1..100000 LOOP
        INSERT INTO course (code,name,credit,offerby) 
            VALUES (counter,'Tahlil',3.00,1010);

END LOOP;
end;
/


SELECT tablespace_name,bytes /1024/1024 MB
FROM dba_free_space
WHERE tablespace_name ='TBS1';

SELECT tablespace_name , bytes /1024/1024 MB
FROM dba_free_space
WHERE tablespace_name ='TBS2';

ALTER TABLESPACE tbs1
ADD DATAFILE 'C:\SWE_STUDIES\Fourth_Semester\DBMS II LAB\lab2\tbs1_data.dbf' SIZE 2m;

ALTER DATABASE
DATAFILE 'C:\SWE_STUDIES\Fourth_Semester\DBMS II LAB\lab2\tbs2.dbf' RESIZE 15m;

select tablespace_name,username,max_bytes/1024/1024 as tb_Size
from dba_ts_quotas where username='FAIYAZ';

DROP TABLESPACE tbs1
INCLUDING CONTENTS AND DATAFILES
CASCADE CONSTRAINTS;

DROP TABLESPACE tbs2
INCLUDING CONTENTS KEEP DATAFILES
CASCADE CONSTRAINTS;











