set SERVEROUTPUT on;
--1--
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

--2--
create or replace Procedure 
topratedmovies(n in number)
As 
    i number;
    c number;
    average number;
    track number;
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
        for row in (select mov_title,rev_stars from movie natural join rating natural join reviewer) loop
        if(row.rev_stars>average and c<=n)then
            DBMS_OUTPUT.PUT_LINE(row.mov_title);
            track:=track+1;
        end if;
    end loop;
    end if;
end;
/

begin
    topratedmovies(200);
end;
/
--3--
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
    from  movie 
    where mov_id=movieid;
    
    select count(mov_id) into n
    from  movie natural join rating natural join reviewer
    where mov_id=movieid and rev_stars>=6
    group by mov_id;
    
    earnings:=(10*n);
    yearly:=earnings/((sysdate-rd)/365);
    
    return yearly;
end;
/

begin
    DBMS_OUTPUT.PUT_LINE('Yearly Income: ' || yearlyearnings(902));
end;
/
--4--
create or replace 
function genrestatusshow(genreid in number)
return varchar2
is
avg_review_of_all_genre number;
avg_rating_of_all_genre number;
val varchar2(150);

    cursor dummytable
    is
        select gen_id,gen_title,avgstars,avg_reviews_per_genre
        from (select GENRES.GEN_ID,avg(REV_ID) as avg_reviews_per_genre
            from genres natural join REVIEWER
            group by genres.gen_id) t1
            natural join
            (select GENRES.GEN_ID,GENRES.GEN_TITLE, avg(rating.rev_stars) as avgstars
            from genres natural join rating
            group by genres.gen_id, GENRES.GEN_TITLE
            order by gen_id) t2;
begin
    select avg(M) into avg_review_of_all_genre
    from(select GENRES.GEN_ID,avg(REV_ID) M
        from genres natural join REVIEWER
        group by genres.gen_id);

    select avg(x) into avg_rating_of_all_genre
    from(select GENRES.GEN_ID,GENRES.GEN_TITLE, avg(rating.rev_stars) as x
        from genres natural join rating
        group by genres.gen_id, GENRES.GEN_TITLE
        order by gen_id);

    FOR row IN dummytable
    LOOP
        if(row.GEN_ID=genreid) then
            if(row.avg_reviews_per_genre>avg_review_of_all_genre and row.avgstars<avg_review_of_all_genre) then
                val:='Widely Watched';
                return val;
            elsif(row.avg_reviews_per_genre<avg_review_of_all_genre and row.avgstars>avg_review_of_all_genre) then
                val:='Highly rated';
                return val;
            elsif(row.avg_reviews_per_genre>avg_review_of_all_genre and row.avgstars>avg_review_of_all_genre) then
                val:='People favourite';
                return val;
            end if;
        end if;
    END LOOP ;
    val:='so so';
    return 'so so';
end;
/

begin
   DBMS_OUTPUT.PUT_LINE(GENRESTATUSSHOW(1012));
end;
/

--5--
create or replace
type freq_genre_and_movie_count as object
(
    genre_id number,
    genre_title varchar(150),
    mov_count number
);

create or replace
function frequent_genre(starting varchar,ending varchar)
return freq_genre_and_movie_count
is
    data freq_genre_and_movie_count;
    genre_id GENRES.GEN_ID%type;
    genre_title GENRES.GEN_TITLE%type;
    countfreq number;

begin
    select GEN_ID,GEN_TITLE,num_of_movies into genre_id,genre_title,countfreq
    from(select GEN_ID,GEN_TITLE,MOV_RELEASEDATE
        from MOVIE natural join GENRES
        where to_date(starting,'DD-MON-YY')<MOV_RELEASEDATE
          and MOV_RELEASEDATE<to_date(ending,'DD-MON-YY') and rownum<=1
        order by MOV_RELEASEDATE)
        natural join
        (select GEN_ID,count(MOV_ID) num_of_movies
        from MOVIE natural join GENRES
        where to_date(starting,'DD-MON-YY')<MOV_RELEASEDATE
          and MOV_RELEASEDATE<to_date(ending,'DD-MON-YY')
        group by GEN_ID);

    data:= freq_genre_and_movie_count(genre_id, genre_title, countfreq);

    return data;
end;
/

declare
    data freq_genre_and_movie_count;

begin
    data:=frequent_genre('31-DEC-1940','31-DEC-1998');
    DBMS_OUTPUT.PUT_LINE(data.GENRE_ID || ' ' || data.GENRE_TITLE || ' ' || data.MOV_COUNT);
end;


























