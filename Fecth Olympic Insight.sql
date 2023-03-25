select *
from olympics_history
where medal <> 'NA';

select noc, count(medal)
from olympics_history oh
where medal = 'Gold'
group by noc
order by 2 desc

select *
from olympics_history_noc_regions;


-- 1.How many olympics games have been held?
SELECT count(distinct games)
from olympics_history;

-- 2.List down all Olympics games held so far.
select distinct year, season, city
from olympics_history
order by year asc;

-- 3.Mention the total no of nations who participated in each olympics game
select oh.games, count(distinct region)
from olympics_history oh
join olympics_history_noc_regions onr
	on oh.noc = onr.noc
group by oh.games

-- 4.Which year saw the highest and lowest no of countries participating in olympics
with join_table as
	(select oh.games, count(distinct region) as country_count
	from olympics_history oh
	join olympics_history_noc_regions onr
		on oh.noc = onr.noc
	group by oh.games)
SELECT
	min(games)||' '||'-'||' '||min(country_count) as lowest_countries,
	max(games)||' '||'-'||' '||max(country_count) as highest_countries
from join_table;


					   
-- 5.Which nation has participated in all 
--   of the olympic games

with join_table as
	(select onr.region, count(distinct games) as games_count
	from olympics_history oh
	join olympics_history_noc_regions onr
		on oh.noc = onr.noc
	group by onr.region)
select *
from join_table
where games_count = (select count(distinct games)
					 from olympics_history);
								  
-- 6.Identify the sport which was played 
--   in all summer olympics

with a as
	(select 
	 	season, 
	 	sport, 
	 	count(distinct year) as count_sport,
	 	count(distinct games) as count_games
	 from olympics_history
	 where season = 'Summer'
	 group by 1,2)
select sport, count_sport, count_games
from a
where count_sport = (select count(distinct games)
					 from olympics_history
					 where season = 'Summer');

--7.Which Sports were just played only once in the olympics?

with a as
	(select season, sport, count(distinct games) as count_sport
	from olympics_history
	group by 1,2)
select sport 
from a
where count_sport = 1;


with b as
	(
	 	select 
			sport,
			count(distinct games) as count_game
		from olympics_history
		group by 1
	)
select distinct b.sport, b.count_game, oh.games
from b b
join olympics_history oh
	on b.sport = oh.sport
where count_game = 1;

--8.Fetch the total no of sports played in each olympic games.
select games, count(distinct sport) as count_sport
from olympics_history
group by 1
order by 2 desc, 1 asc;

--9.Fetch details of the oldest athletes to win a gold medal.
with dump as
(
	select
		*,
		cast(case when age = 'NA' then '0' else age end as int) as age_int
	from olympics_history
)
select name, sex, age, team, games, city, sport, event, medal
from dump
where age_int = (select max(age_int)
				 from dump
				 where medal = 'Gold')
  and medal = 'Gold';
  
--10. Find the Ratio of male and female athletes 
--  participated in all olympic games.
SELECT
	(select count(sex) 
	from olympics_history
	where sex = 'F')
	/(select count(sex) 
	from olympics_history
	where sex = 'F')
	|| ':' ||
	round(round((select count(sex) 
	from olympics_history
	where sex = 'M'),2)
	/round((select count(sex) 
	from olympics_history
	where sex = 'F'),2),2)
	as ratio

--11. Fetch the top 5 athletes who have won 
--   the most gold medals.

select oh.name, oh.team, count(oh.name)
from olympics_history oh
where oh.medal = 'Gold'
group by 1,2
order by 3 DESC
limit 6;

--12. Fetch the top 5 athletes who have won 
-- the most medals (gold/silver/bronze).
select oh.name, oh.team, count(oh.name)
from olympics_history oh
where oh.medal <> 'NA'
group by 1,2
order by 3 DESC
limit 6;

--13.Fetch the top 5 most successful countries in olympics. 
-- Success is defined by no of medals won.
with rnk as
(SELECT 
	ohnr.region, 
	count(ohnr.region) as total_medal,
	Rank() OVER(order by count(ohnr.region) desc) as rank_olym
from olympics_history oh
join olympics_history_noc_regions ohnr
	ON oh.noc = ohnr.noc
	where oh.medal <> 'NA'
group by 1)
select *
from rnk
where rank_olym <=5;

--14. List down total gold, silver and bronze medals won by each country.
with country as
	(select nr.region, count(medal) as total
	from olympics_history oh
	join olympics_history_noc_regions nr
		on oh.noc = nr.noc
	where medal <> 'NA'
	group by 1),
gold as
	(select 
		ohnr.region,
		count(ohnr.noc) as gold
	from olympics_history oh
	join olympics_history_noc_regions ohnr
		ON oh.noc = ohnr.noc
	where oh.medal = 'Gold'
	group by 1),
silver as 
	(select 
		ohnr.region,
		count(ohnr.noc) as silver
	from olympics_history oh
	join olympics_history_noc_regions ohnr
		ON oh.noc = ohnr.noc
	where oh.medal = 'Silver'
	group by 1),
bronze as 
	(select 
		ohnr.region,
		count(ohnr.noc) as bronze
	from olympics_history oh
	join olympics_history_noc_regions ohnr
		ON oh.noc = ohnr.noc
		where oh.medal = 'Bronze'
	group by 1)
select 
	c.region,
	g.gold,
	s.silver,
	b.bronze,
	c.total
from country c
join gold g
	on c.region = g.region
join silver s
	on g.region = s.region
join bronze b
	on s.region = b.region
order by 2 desc,3 desc,4 desc;

--15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
with country as
(select oh.games, nr.region, 
 	count(medal) as total
from olympics_history oh
join olympics_history_noc_regions nr
	on oh.noc = nr.noc
where medal <> 'NA'
group by 2,1),
gold as
(select 
 	oh.games, ohnr.region,
 	count(ohnr.region) as gold
from olympics_history oh
join olympics_history_noc_regions ohnr
	ON oh.noc = ohnr.noc
where oh.medal = 'Gold'
group by 1,2),
silver as 
(select 
 	oh.games, ohnr.region,
 	count(ohnr.region) as silver
from olympics_history oh
join olympics_history_noc_regions ohnr
	ON oh.noc = ohnr.noc
where oh.medal = 'Silver'
group by 1,2),
bronze as 
(select 
 	oh.games, ohnr.region,
 	count(ohnr.region) as bronze
from olympics_history oh
join olympics_history_noc_regions ohnr
	ON oh.noc = ohnr.noc
	where oh.medal = 'Bronze'
group by 1,2)
select
	c.games,
	c.region,
	coalesce(g.gold, 0) as gold, 
	coalesce(s.silver, 0) as silver,
	coalesce(b.bronze,0) as bronze
from country c
join gold g
	on c.games = g.games and
	c.region = g.region
left join silver s
	on c.games= s.games and
	c.region = s.region
left join bronze b
	on c.games = b.games and
	c.region = b.region
order by 1 asc, 2 asc,3 desc,4 desc, 5 desc;


/* Alternative Answer */
DROP EXTENSION IF EXISTS TABLEFUNC;
CREATE EXTENSION TABLEFUNC;
SELECT substring(games,1,position(' - ' in games) - 1) as games
	, substring(games,position(' - ' in games) + 3) as country
	, coalesce(gold, 0) as gold
	, coalesce(silver, 0) as silver
	, coalesce(bronze, 0) as bronze
FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
			, medal
			, count(1) as total_medals
			FROM olympics_history oh
			JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
			where medal <> ''NA''
			GROUP BY games,nr.region,medal
			order BY games,medal',
		'values (''Bronze''), (''Gold''), (''Silver'')')
AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint);

/*
16. Identify which country won the most gold, 
most silver and most bronze medals in each olympic games.
*/

with gold as
(select oh.games, nr.region, count(medal) as total,
	RANK() OVER(PARTITION BY oh.games ORDER BY count(medal) desc, nr.region asc) as rnk
from olympics_history oh
join olympics_history_noc_regions nr
	on oh.noc = nr.noc
where medal = 'Gold'
group by 1,2),
silver as
(select oh.games, nr.region, count(medal) as total,
	RANK() OVER(PARTITION BY oh.games ORDER BY count(medal) desc, nr.region asc) as rnk
from olympics_history oh
join olympics_history_noc_regions nr
	on oh.noc = nr.noc
where medal = 'Silver'
group by 1,2),
bronze as
(select oh.games, nr.region, count(medal) as total,
	RANK() OVER(PARTITION BY oh.games ORDER BY count(medal) desc, nr.region asc) as rnk
from olympics_history oh
join olympics_history_noc_regions nr
	on oh.noc = nr.noc
where medal = 'Bronze'
group by 1,2)
SELECT
	g.games,
	g.region||' '||'-'||' '||g.total as max_gold,
	s.region||' '||'-'||' '||s.total as max_silver,
	b.region||' '||'-'||' '||b.total as max_bronze
from gold g
left join silver s
	on g.games = s.games
left join bronze b
	on g.games = b.games
where g.rnk = 1
 and s.rnk =1
 and b.rnk =1

/* Alternative Answer*/
WITH temp as
	(SELECT substring(games, 1, position(' - ' in games) - 1) as games
		, substring(games, position(' - ' in games) + 3) as country
		, coalesce(gold, 0) as gold
		, coalesce(silver, 0) as silver
		, coalesce(bronze, 0) as bronze
	FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
					, medal
					, count(1) as total_medals
				  FROM olympics_history oh
				  JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
				  where medal <> ''NA''
				  GROUP BY games,nr.region,medal
				  order BY games,medal',
			  'values (''Bronze''), (''Gold''), (''Silver'')')
			   AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint))
select distinct games
	, concat(first_value(country) over(partition by games order by gold desc)
			, ' - '
			, first_value(gold) over(partition by games order by gold desc)) as Max_Gold
	, concat(first_value(country) over(partition by games order by silver desc)
			, ' - '
			, first_value(silver) over(partition by games order by silver desc)) as Max_Silver
	, concat(first_value(country) over(partition by games order by bronze desc)
			, ' - '
			, first_value(bronze) over(partition by games order by bronze desc)) as Max_Bronze
from temp
order by games;

/*
17. Identify which country won the most gold, most silver, 
most bronze medals and the most medals in each olympic games.
*/


with gold as
	(select oh.games, nr.region, count(medal) as total,
		RANK() OVER(PARTITION BY oh.games ORDER BY count(medal) desc, nr.region asc) as rnk
	from olympics_history oh
	join olympics_history_noc_regions nr
		on oh.noc = nr.noc
	where medal = 'Gold'
	group by 1,2),
silver as
	(select oh.games, nr.region, count(medal) as total,
		RANK() OVER(PARTITION BY oh.games ORDER BY count(medal) desc, nr.region asc) as rnk
	from olympics_history oh
	join olympics_history_noc_regions nr
		on oh.noc = nr.noc
	where medal = 'Silver'
	group by 1,2),
bronze as
	(select oh.games, nr.region, count(medal) as total,
		RANK() OVER(PARTITION BY oh.games ORDER BY count(medal) desc, nr.region asc) as rnk
	from olympics_history oh
	join olympics_history_noc_regions nr
		on oh.noc = nr.noc
	where medal = 'Bronze'
	group by 1,2),
country as
	(select oh.games, nr.region, count(medal) as total,
	 	RANK() OVER(PARTITION BY oh.games ORDER BY count(medal) desc, nr.region asc) as rnk
	 from olympics_history oh
	 join olympics_history_noc_regions nr
		on oh.noc = nr.noc
	 where medal <> 'NA'
	 group by 1,2)
SELECT
	c.games,
	g.region||' '||'-'||' '||g.total as max_gold,
	s.region||' '||'-'||' '||s.total as max_silver,
	b.region||' '||'-'||' '||b.total as max_bronze,
	c.region||' '||'-'||' '||c.total as max_medal
from country c
left join gold g
	on c.games = g.games
left join silver s
	on c.games = s.games
left join bronze b
	on c.games = b.games
where g.rnk = 1
 and s.rnk =1
 and b.rnk =1
 and c.rnk =1
 
 
 /*
 18. Which countries have never 
 won gold medal but have won silver/bronze medals?
 */
 
 
 with 
 country as
	(select distinct nr.region
	 from olympics_history oh
	 join olympics_history_noc_regions nr
		on oh.noc = nr.noc
	 where medal <> 'NA'),
 gold as
 	(select 
		nr.region, count(medal) as total
	 from olympics_history oh
	 join olympics_history_noc_regions nr
		on oh.noc = nr.noc
	 where medal = 'Gold'
	 group by 1),
silver as
	(select 
		nr.region, count(medal) as total
	 from olympics_history oh
	 join olympics_history_noc_regions nr
		on oh.noc = nr.noc
	 where medal = 'Silver'
	 group by 1),
bronze as
	(select 
		nr.region, count(medal) as total
	 from olympics_history oh
	 join olympics_history_noc_regions nr
		on oh.noc = nr.noc
	 where medal = 'Bronze'
	 group by 1)
select 
	c.region,
	COALESCE(g.total, 0) as gold,
	coalesce(s.total, 0) as silver,
	coalesce(b.total, 0) as bronze
from country c
left join gold g
	on c.region = g.region
left join silver s
	on c.region = s.region
left join bronze b
	on c.region = b.region
order by 2 asc, 3 desc, 4 desc

/*
 19.In which Sport/event, India has won highest medals.
*/

with
india as
	(select 
		sport,
		count(medal) as total_medal,
		rank() over(order by count(medal) desc) as numb
	from 
		olympics_history
	WHERE
		noc = 'IND'
	and medal <> 'NA'
	group by
		1)
select sport, total_medal
from india
where numb = 1;

/*
 20.Break down all olympic games where India won 
 medal for Hockey and how many medals in each olympic games
*/

select
	team,
	sport,
	games,
	count(medal)
from olympics_history
where team = 'India'
and sport = 'Hockey'
and medal <> 'NA'
group by 1,2, 3
order by 4 desc;

select team, sport, games, count(1) as total_medals
    from olympics_history
    where medal <> 'NA'
    and team = 'India' and sport = 'Hockey'
    group by team, sport, games
    order by total_medals desc;