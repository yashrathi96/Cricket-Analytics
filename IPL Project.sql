create database IPL_db;

use IPL_db;

/*For ipl_ball table*/

select count(*) 
from ipl_ball;

select *
from ipl_ball
limit 20;

select match_date, if(match_date like "%/%",
str_to_date(match_date,"%d/%m/%Y"),
str_to_date(match_date,"%d-%m-%Y"))
from ipl_ball;

alter table ipl_ball
add column match_date_new date;

set sql_safe_updates = 0;

update ipl_ball
set match_date_new = if(match_date like "%/%",
str_to_date(match_date,"%d/%m/%Y"),
str_to_date(match_date,"%d-%m-%Y"));

select match_date_new
from ipl_ball
limit 30;

/*For ipl_matches table*/

select count(*) 
from ipl_matches;

select * 
from ipl_matches
limit 20;

select date, if(date like "%/%",
str_to_date(date,"%d/%m/%Y"),
str_to_date(date,"%d-%m-%Y"))
from ipl_matches;

alter table ipl_matches
add column date_new date;

set sql_safe_updates = 0;

update ipl_matches
set date_new = if(date like "%/%",
str_to_date(date,"%d/%m/%Y"),
str_to_date(date,"%d-%m-%Y"));

select date_new
from ipl_matches
limit 30;


/*Select the top 20 rows of the matches table*/

select * 
from ipl_matches
limit 20;

/*Fetch data of all the matches played on 2nd May 2013*/

select * 
from ipl_matches
where date_new = "2013-05-02";


/*Fetch data of all the matches where the margin of victory is more than 100 runs*/

select * 
from ipl_matches 
where result = "runs" and result_margin > 100;

/*Fetch data of all the matches where the final scores of both teams tied and order it in descending order of the date*/

select * 
from ipl_matches
where result="tie"
order by date_new desc;

/*Get the count of cities that have hosted an IPL match*/

select city, count(*) as CityCount
from ipl_matches 
group by city;

/*Create table deliveries_v02 with all the columns of deliveries 
and an additional column ball_result containing value boundary, dot or other depending 
on the total_run (boundary for >= 4, dot for 0 and other for any other number)*/

create table deliveries_v02
select *, case when total_runs >= 4 then "boundary"
when total_runs = 0 then "dot"
else "other"
end as ball_result
from ipl_ball;

select ball_result
from deliveries_v02;

/*Write a query to fetch the total number of boundaries and dot balls*/

select ball_result, count(*) as Total
from deliveries_v02
where ball_result in ("boundary","dot")
group by ball_result;

/*Write a query to fetch the total number of boundaries scored by each team*/

select distinct batting_team, count(*) as Total_Boundaries
from deliveries_v02
where ball_result = "boundary"
group by batting_team;

/*Write a query to fetch the total number of dot balls bowled by each team*/

select distinct bowling_team, count(*) as Total_Dots
from deliveries_v02
where ball_result="dot"
group by bowling_team;

/*Write a query to fetch the total number of dismissals by dismissal kinds*/

select dismissal_kind, count(*) as Total_Dismissals
from deliveries_v02
where dismissal_kind <> "NA"
group by dismissal_kind;

/*Write a query to get the top 5 bowlers who conceded maximum extra runs*/

select distinct bowler, sum(extra_runs) as Extra
from deliveries_v02
where extras_type <> "NA"
group by bowler
order by sum(extra_runs) desc
limit 5;

/*Write a query to create a table named deliveries_v03 with all the columns of deliveries_v02 table and 
two additional column (named venue and match_date) of venue and date from table matches*/

create table deliveries_v03
select dv2.id, inning, 'over', ball, batsman, non_striker, bowler, batsman_runs, extra_runs, total_runs, is_wicket, 
dismissal_kind,player_dismissed, fielder, extras_type, batting_team, bowling_team, ball_result, m.venue, date_new
from deliveries_v02 dv2 inner join ipl_matches m
using(id);

/*Write a query to fetch the total runs scored for each venue and order it in the descending order of total runs scored*/ 

select distinct venue, sum(total_runs) as TotalRuns
from deliveries_v03 
group by venue
order by TotalRuns desc;

/*Write a query to fetch the year-wise total runs scored at Eden Gardens and order it in the descending order of total runs scored*/

select year(date_new) as years, sum(total_runs) as TotalRuns
from deliveries_v03
where venue = "Eden Gardens"
group by years
order by TotalRuns desc;

/*Get unique team1 names from the matches table, 
you will notice that there are two entries for Rising Pune Supergiant one with Rising Pune Supergiant and 
another one with Rising Pune Supergiants. 
Your task is to create a matches_corrected table with two additional columns team1_corr and team2_corr 
containing team names with replacing Rising Pune Supergiants with Rising Pune Supergiant. 
Now analyse these newly created columns*/

create table matches_corrected
select * 
from ipl_matches;

alter table matches_corrected
add column team1_corr varchar(225),
add column team2_corr varchar(225);

set sql_safe_updates = 0;

update matches_corrected
set team1_corr = if(team1 = "Rising Pune Supergiants", "Rising Pune Supergiant", team1),
team2_corr = if(team2 = "Rising Pune Supergiants", "Rising Pune Supergiant", team2);

drop table matches_corrected;

select distinct team1_corr
from matches_corrected;

select distinct team2_corr
from matches_corrected;

/*Create a new table deliveries_v04 with the first column as ball_id containing information of 
match_id, inning, over and ball separated by'(For ex. 335982-1-0-1 match_idinning-over-ball) and rest of the columns same as deliveries_v03)*/

create table deliveries_v04
select *, concat(id, "-",inning,"-", 'over',"-", ball) as Ball_id
from deliveries_v03;

select *
from deliveries_v04;

/*Compare the total count of rows and total count of distinct ball_id in deliveries_v04*/

select count(distinct id) as distinctMatches, 
count(ball_id) as totalrows
from deliveries_v04;

/*Create table deliveries_v05 with all columns of deliveries_v04 and 
an additional column for row number partition over ball_id. (HINT : row_number() over (partition by ball_id) as r_num)*/

create table deliveries_v05
select *, row_number() over (partition by ball_id) as r_num
from deliveries_v04;

/*Use the r_num created in deliveries_v05 to identify instances where ball_id is repeating. 
(HINT : select * from deliveries_v05 WHERE r_num=2;)*/

select *
from deliveries_v05
where r_num = 2;

/*Use subqueries to fetch data of all the ball_id which are repeating. 
(HINT: SELECT * FROM deliveries_v05 WHERE ball_id in (select BALL_ID from deliveries_v05 WHERE r_num=2)*/

select * 
from deliveries_v05
where ball_id in (select Ball_id from deliveries_v05 where r_num=2);

