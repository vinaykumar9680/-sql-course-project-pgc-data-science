--creating table iplball

create table ipl_ball (id int,inning int,over int,ball int,batsman varchar(100),non_striker varchar(100),bowler varchar(100),batsmen_runs int,extra_run int,total_runs int,is_wicket int,dismissal_kind varchar(100),pyaler_dismissal varchar(100),fielder varchar(100),extras_type varchar(100),batting_team varchar(100),bowling_team varchar(100) );

--copy data from csv in ipl ball

copy ipl_ball from 'C:\Program Files\PostgreSQL\16\data\copy data\IPL_Ball.csv' delimiter ',' csv header;

--showing data of iplball

select * from ipl_ball;



--selecting data for batsmen stats

select count(distinct (id)) as matches_played ,batsman,count(ball) as ball_played ,sum(batsmen_runs) as total_runs , sum(is_wicket) as times_out,
case when sum(is_wicket)>0 then (SUM(batsmen_runs) / NULLIF(SUM(is_wicket), 0)) else SUM(batsmen_runs) end AS average_runs,
    (SUM(batsmen_runs) * 100.0) / NULLIF( COUNT(*) , 0) AS strike_rate , SUM(CASE WHEN batsmen_runs = 4 THEN 1 ELSE 0 END) AS fours,
    SUM(CASE WHEN batsmen_runs = 6 THEN 1 ELSE 0 END) AS sixes,SUM(CASE WHEN batsmen_runs IN (4, 6) THEN 1 ELSE 0 END) AS total_boundaries  from ipl_ball where not extras_type= 'wides' group by batsman;

--making table of batsmen stats data


create table batsmen_stats as select count(distinct (id)) as matches_played ,batsman,count(ball) as ball_played ,sum(batsmen_runs) as total_runs , sum(is_wicket) as times_out,
case when sum(is_wicket)>0 then (SUM(batsmen_runs) / NULLIF(SUM(is_wicket), 0)) else SUM(batsmen_runs) end AS average_runs,
    (SUM(batsmen_runs) * 100.0) / NULLIF( COUNT(*) , 0) AS strike_rate , SUM(CASE WHEN batsmen_runs = 4 THEN 1 ELSE 0 END) AS fours,
    SUM(CASE WHEN batsmen_runs = 6 THEN 1 ELSE 0 END) AS sixes,SUM(CASE WHEN batsmen_runs IN (4, 6) THEN 1 ELSE 0 END) AS total_boundaries  from ipl_ball where not extras_type= 'wides' group by batsman;

--showing demo data of batsmen stats 

select * from  batsmen_stats ;


--selecting data for bowler stats


SELECT 
    bowler,
    COUNT(DISTINCT id) AS matches_played,
    COUNT(ball) AS balls_delivered,SUM(batsmen_runs + CASE WHEN extras_type NOT IN ('byes', 'legbyes') THEN extra_run ELSE 0 END) as runs_conseed,
(SUM(batsmen_runs + CASE WHEN extras_type NOT IN ('byes', 'legbyes') THEN extra_run ELSE 0 END) / (COUNT(*) / 6.0)) AS economy,
    COUNT(ball) / NULLIF(SUM(is_wicket), 0) AS strike_rate,
    SUM(is_wicket) AS wickets_taken
FROM 
    IPL_Ball

GROUP BY 
    bowler;

-- creating table from bowler stats

create table bowler_stats as 
SELECT 
    bowler,
    COUNT(DISTINCT id) AS matches_played,
    COUNT(ball) AS balls_delivered,SUM(batsmen_runs + CASE WHEN extras_type NOT IN ('byes', 'legbyes') THEN extra_run ELSE 0 END) as runs_conseed,
(SUM(batsmen_runs + CASE WHEN extras_type NOT IN ('byes', 'legbyes') THEN extra_run ELSE 0 END) / (COUNT(*) / 6.0)) AS economy,
    COUNT(ball) / NULLIF(SUM(is_wicket), 0) AS strike_rate,
    SUM(is_wicket) AS wickets_taken
FROM 
    IPL_Ball

GROUP BY 
    bowler;

--showing demo of  table bowler_stats

select * from bowler_stats;

/* Your first priority is to get 2-3 players with high S.R who have faced at least 500 balls.
And to do that you have to make a list of 10 players you want to bid in the auction so that when 
you try to grab them in auction you should not pay the amount greater than you have in the purse 
for a particular player.*/

select batsman ,ball_played,strike_rate from batsmen_stats where ball_played>500 
order by strike_rate desc
limit 10;

/* Now you need to get 2-3 players with good Average who have played more the 2 ipl seasons.
And to do that you have to make a list of 10 players you want to bid in the auction so that
when you try to grab them in auction you should not pay the amount greater than you have in 
the purse for a particular player. */

select batsman,matches_played,average_runs from batsmen_stats where matches_played>28
order by average_runs desc
limit 10;

/* Now you need to get 2-3 Hard-hitting players who have scored most runs in boundaries and have
played more the 2 ipl season. To do that you have to make a list of 10 players you want to bid in
the auction so that when you try to grab them in auction you should not pay the amount greater than
you have in the purse for a particular player.*/

SELECT
    batsman,matches_played,
    total_runs,fours,sixes,
    (fours * 4 + sixes * 6) AS total_boundary_runs,
    CASE
        WHEN total_runs = 0 THEN 0
        ELSE ((fours * 4 + sixes * 6) / total_runs::float) * 100
    END AS boundary_percentage
FROM
    batsmen_stats
	where 
	matches_played>28
ORDER BY
    boundary_percentage DESC
	limit 10;


/* Your first priority is to get 2-3 bowlers with good economy who have bowled at least 500 balls 
in IPL so far.To do that you have to make a list of 10 players you want to bid in the auction so 
that when you try to grab them in auction you should not pay the amount greater than you have in 
the purse for a particular player.*/

select bowler,matches_played , balls_delivered ,economy from bowler_stats 
	where balls_delivered>500
order by economy 
limit 10;

/* Now you need to get 2-3 bowlers with the best strike rate and who have bowled at least 500 balls
in IPL so far.To do that you have to make a list of 10 players you want to bid in the auction so that
when you try to grab them in auction you should not pay the amount greater than you have in the purse
for a particular player.*/

select bowler,matches_played,balls_delivered,strike_rate from bowler_stats 
	where balls_delivered>500
order by strike_rate
limit 10;

/* Now you need to get 2-3 All_rounders with the best batting as well as bowling strike rate and who 
have faced at least 500 balls in IPL so far and have bowled minimum 300 balls.To do that you have
to make a list of 10 players you want to bid in the auction so that when you try to grab them in 
auction you should not pay the amount greater than you have in the purse for a particular player.*/

-- selecting data for allrounder

select a.matches_played,a.batsman  as allrounder,a.ball_played,a.total_runs,a.average_runs,
	a.strike_rate,a.fours,a.sixes,b.balls_delivered,b.runs_conseed,b.economy,b.strike_rate,b.wickets_taken 
	from batsmen_stats as a join bowler_stats as b
on a.batsman=b.bowler;


-- creating table for allrounders_stats

create table allrounder_stats as select a.matches_played,a.batsman  as allrounder,a.ball_played,a.total_runs,a.average_runs,a.strike_rate as batting_strikerate
	,a.fours,a.sixes,b.balls_delivered,b.runs_conseed,b.economy,b.strike_rate as bowling_strikerate,b.wickets_taken 
	from batsmen_stats as a join bowler_stats as b
on a.batsman=b.bowler;

--showig data of all rounder

select * from allrounder_stats;

-- selecting allrounder for team

select allrounder,ball_played,batting_strikerate,balls_delivered, bowling_strikerate
from allrounder_stats
where ball_played>499 and balls_delivered>299
order by batting_strikerate desc,bowling_strikerate desc
	limit 10;

/* selecting a wicketkeeper for a team*/

select * from batsmen_stats;


select a.matches_played,a.batsman,a.strike_rate,b.catches_taken from batsmen_stats as a join (select fielder,count(dismissal_kind) as catches_taken
	from ipl_ball where fielder in (select distinct(fielder) from ipl_ball where dismissal_kind='caught')
	group by fielder
	order by catches_taken desc limit 30
	) as b on b.fielder=a.batsman
	where a.batsman in ('MS Dhoni','KD Karthik','RV Uthappa','AB de Villiers','PA Patel','WP Saha','NV Ojha','AC Gilchrist','Q de Kock','RR Pant','KC Sangakkara') 
	order by strike_rate desc limit 5;

	
	

-- additional questions




--creating table deliveries

create table deliveries (id int,inning int,over int,ball int,batsman varchar(100),non_striker varchar(100),bowler varchar(100),batsmen_runs int,extra_run int,total_runs int,is_wicket int,dismissal_kind varchar(100),pyaler_dismissal varchar(100),fielder varchar(100),extras_type varchar(100),batting_team varchar(100),bowling_team varchar(100) );

--copy data from csv in ipl ball

copy deliveries from 'C:\Program Files\PostgreSQL\16\data\copy data\IPL_Ball.csv' delimiter ',' csv header;

--showing data of iplball

select * from deliveries;

--creating table ipl maches

create table matches (id int,city varchar(100),date date,player_of_match varchar(100),venue varchar(200),neutral_vanue int,team1 varchar(100),team2 varchar(100),toss_winnwe varchar(100),toss_decision varchar(100),winner varchar(100),result varchar(100),result_margin int,eliminator varchar(100),method varchar(100),umpire1 varchar(100),umpire2 varchar(100));

--copy data from csv in ipl maches

copy matches from 'C:\Program Files\PostgreSQL\16\data\copy data\IPL_matches.csv' delimiter ',' csv header;

--showing data of ipl_maches

select * from matches;

--Get the count of cities that have hosted an IPL match?

select  count(distinct city)  as count_ofcities from matches;

/* Create table deliveries_v02 with all the columns of the table ‘deliveries’ and an additional
column ball_result containing values boundary, dot or other depending on the total_run
(boundary for >= 4, dot for 0 and other for any other number)
(Hint 1 : CASE WHEN statement is used to get condition based results)
(Hint 2: To convert the output data of the select statement into a table, you can use a
subquery. Create table table_name as [entire select statement].*/

CREATE TABLE DELIVERIES_V02 AS
SELECT id,inning,over,ball,batsman,non_striker,bowler,batsmen_runs,extra_run,total_runs,is_wicket,dismissal_kind,
pyaler_dismissal as player_dissmisal,fielder,extras_type,batting_team,bowling_team ,CASE  WHEN total_runs >= 4 THEN 'boundary' WHEN total_runs = 0 THEN 'dot' ELSE 'other' END AS ball_result
FROM DELIVERIES;

--selecting deliveries v02 data

select * from DELIVERIES_V02;

/* Write a query to fetch the total number of boundaries and dot balls from the
deliveries_v02 table */

SELECT 
    SUM(CASE WHEN ball_result = 'boundary' THEN 1 ELSE 0 END) AS total_boundaries,
    SUM(CASE WHEN ball_result = 'dot' THEN 1 ELSE 0 END) AS total_dot_balls
FROM deliveries_v02;

/*Write a query to fetch the total number of boundaries scored by each team from the
deliveries_v02 table and order it in descending order of the number of boundaries
scored*/

select distinct(batting_team) as team_name , SUM(CASE WHEN ball_result='boundary' then 1 else 0 END) as total_boundaries
from DELIVERIES_V02 
GROUP BY batting_team
	order by total_boundaries desc;

/* Write a query to fetch the total number of dot balls bowled by each team and order it in
descending order of the total number of dot balls bowled.*/

select distinct(bowling_team) as team_name , SUM(CASE WHEN ball_result='dot' then 1 else 0 END) as total_dotballs
from DELIVERIES_V02 
GROUP BY bowling_team
	order by total_dotballs desc;


/* Write a query to fetch the total number of dismissals by dismissal kinds where dismissal
kind is not NA */

select distinct(dismissal_kind),count(dismissal_kind)
from deliveries
where NOT dismissal_kind='NA'
	group by dismissal_kind;

/* Write a query to get the top 5 bowlers who conceded maximum extra runs from the
deliveries table */

select bowler,sum(extra_run) as extra_runs 
from deliveries
group by bowler
order by extra_runs desc
	limit 5;

/* Write a query to create a table named deliveries_v03 with all the columns of
deliveries_v02 table and two additional column (named venue and match_date) of venue
and date from table matches*/

create table deliveries_v03 as select d.*,m.venue,
    m.date as match_date
from DELIVERIES_V02 as d join matches as m
on m.id=d.id;

select * from deliveries_v03;

/* Write a query to fetch the total runs scored for each venue and order it in the descending
order of total runs scored*/

select venue,sum(total_runs) as total_runs 
from deliveries_v03
group by venue
order by total_runs desc;

/* Write a query to fetch the year-wise total runs scored at Eden Gardens and order it in the
descending order of total runs scored*/

select extract(year from match_date) as year ,sum(total_runs) as total_runs from deliveries_v03
where venue = 'Eden Gardens'
	group by extract(year from match_date)
	order by total_runs desc;



