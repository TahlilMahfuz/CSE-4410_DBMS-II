set SERVEROUTPUT on;
--A--
create or replace Procedure 
requiredtime(title in varchar)
As 
    time number;
    hour number;
    minute number;
    intermission number;
    c number;
begin
    select mov_time into time
    from movie
    where mov_title=title;
    
    DBMS_OUTPUT.PUT_LINE( 'time:' || time/2);
    
    hour:=round(time/60);
    minute:=time-hour*60;
    c:=round(time/70);
    if((time-(c-1)*70)>=30) THEN
        intermission:=c*15;
    else
        intermission:=(c-1)*15;
    end if;
    if(hour<1 and time>70)then
        DBMS_OUTPUT.PUT_LINE( '1HOUR:' || hour || ' ');
    elsif(hour>1 and time<70) then
        DBMS_OUTPUT.PUT_LINE( '2HOUR:' || hour || ' ' || 'Minute:' || Minute || ' ');
    else
        DBMS_OUTPUT.PUT_LINE( '3HOUR:' || hour || ' ' || 'Minute:' || Minute || ' ' || 'Intermission(mins):' ||intermission);
    end if;
end;
/

begin
    requiredtime('Vertigo');
end;
/

--B--
create or replace Procedure 
topratedmovies(n in number)
As 
    i number;
    c number;
    average number;
begin
    select avg(rev_stars) into average
    from movie natural join rating natural join reviewer;
    
    i:=0;
    c:=0;
    
    for row in (select mov_title,rev_stars from movie natural join rating natural join reviewer) loop
        if(row.rev_stars>average)then
            c:=c+1;
        end if;
    end loop;
    if(c>n)then
        DBMS_OUTPUT.PUT_LINE('Error');
    else
        for row in (select mov_title,rev_stars from movie natural join rating natural join reviewer
                    fetch first n rows only) loop
        if(row.rev_stars>average)then
            DBMS_OUTPUT.PUT_LINE(row.mov_title);
        end if;
    end loop;
    end if;
end;
/

begin
    topratedmovies(10);
end;
/
--C--
create or replace 
function yearlyearnings(movieid number)
return number
is
earnings number;
yearly number;
rd date;
n number;
begin
    earnings:=1;
    
    select mov_releasedate into rd
--    select mov_id,mov_releasedate
    from  movie 
    where mov_id=movieid;
    
    select count(mov_id) into n
    from  movie natural join rating natural join reviewer
    where mov_id=901 and rev_stars>=6
    group by mov_id;
    
    earnings:=(10*n);
--    DBMS_OUTPUT.PUT_LINE('Sys '||sysdate);
--    DBMS_OUTPUT.PUT_LINE('rd '||rd);
--    DBMS_OUTPUT.PUT_LINE('Sys-rd '||(sysdate-rd));
    yearly:=earnings/((sysdate-rd)/365);
    
    return yearly;
end;
/

set serveroutput on;

begin
    DBMS_OUTPUT.PUT_LINE('Yearly Income: ' || yearlyearnings(902));
end;
/
--D--
create or replace 
function genrestatus(genreid number)
return VARCHAR
is
avgstars number;
rcount number;
avgstars number;
begin
--    select genres.gen_id,avg(rating.rev_stars) into avgstars
    select genres.gen_id,avg(rating.rev_stars) into avgstars
    from genres natural join rating
    where gen_id=genreid
    group by genres.gen_id;
    
    select genres.gen_id,count(unique rating.rev_id) into rcount
    from genres natural join rating
    where genreid=genres.gen_id
    group by genres.gen_id;
    
    if(avgstars>rcount) then
        DBMS_OUTPUT.PUT_LINE(avgstars || rcount);
        return 'Widely watched';
    elsif (avgstarts<rcount) then
        DBMS_OUTPUT.PUT_LINE(avgstars || rcount);
        return 'Highly rated';
    else
        DBMS_OUTPUT.PUT_LINE(avgstars || rcount);
        return 'Peoples Favourite';
    end if;
end;
/

--E--
create or replace 
function getfrequentgenre(start date,end date)
return varchar
is
f_genre number;
numofmovies number;
begin
--    select gen_id,genres.gen_title
--    from movie natural join genres
--    where start<=movie.mov_releasedate and movie.releasedate>=end
--    order by movie.mov_releasedate
--    fetch first 1 row only;

    select gen_id into f_genre,genres.gen_title
    from movie natural join genres
    where start<=movie.mov_releasedate and movie.releasedate>=end
    order by movie.mov_releasedate
    fetch first 1 row only;
    
    select count(mov_id) into numofmovies
    from movie natural join genres
    where gen_id=f_genre and start<=movie.mov_releasedate and movie.releasedate>=end;
    
    earnings:=(10*n);
--    DBMS_OUTPUT.PUT_LINE('Sys '||sysdate);
--    DBMS_OUTPUT.PUT_LINE('rd '||rd);
--    DBMS_OUTPUT.PUT_LINE('Sys-rd '||(sysdate-rd));
    yearly:=earnings/((sysdate-rd)/365);
    
    return yearly;
end;
/




















