set search_path to 'public';


-- select * from player_seasons;

-- create TYPE season_stats AS(
-- 	season INTEGER,
-- 	gp INTEGER,
-- 	pts REAL,
-- 	reb REAL,
-- 	ast REAL
-- )

-- create TABLE players(
-- 	player_name TEXT,
-- 	height TEXT,
-- 	college TEXT,
-- 	country TEXT,
-- 	draft_year TEXT,
-- 	draft_round TEXT,
-- 	draft_number TEXT,
-- 	season_stats season_stats[],
-- 	current_season INTEGER,
-- 	PRIMARY KEY(player_name,current_season)
-- )

-- Drop table players;


select MIN(season) from player_seasons;


create type scoring_class as enum('star','good','average','bad');
create TABLE players(
	player_name TEXT,
	height TEXT,
	college TEXT,
	country TEXT,
	draft_year TEXT,
	draft_round TEXT,
	draft_number TEXT,
	season_stats season_stats[],
	scoring_class scoring_class,
	years_since_last_season Integer,
	current_season INTEGER,
	PRIMARY KEY(player_name,current_season)
);

--drop table players;
select MIN(season) from player_seasons;

insert into players
WITH yesterday as (
SELECT * from players
	where current_season = 2000
),
	today as (
	select * from player_seasons
	where season = 2001
	)
select 
COALESCE(t.player_name, y.player_name) as player_name,
COALESCE(t.height, y.height) as height,
COALESCE(t.college, y.college) as college,
COALESCE(t.country, y.country) as country,
COALESCE(t.draft_year, y.draft_year) as draft_year,
COALESCE(t.draft_round, y.draft_round) as draft_round,
COALESCE(t.draft_number, y.draft_number) as draft_number,
CASE WHEN y.season_stats IS NULL
	THEN ARRAY[ROW(
				  t.season,
				  t.gp,
				  t.pts,
				  t.reb,
				  t.ast
				  )::season_stats]
	WHEN t.season IS NOT NULL THEN y.season_stats || ARRAY[ROW(
				  t.season,
				  t.gp,
				  t.pts,
				  t.reb,
				  t.ast
				  )::season_stats]
	ELSE y.season_stats
	END as season_stats,
	case
		when t.season is not null then 
		case when t.pts>20 then 'star'
			 when t.pts>15 then 'good'
			 when t.pts>10 then 'average'
			 else 'bad'
		end::scoring_class
		else y.scoring_class
	end as scoring_class,
	case 
		when t.season is not null then 0
		else y.years_since_last_season + 1
	end as years_since_last_season,
	coalesce(t.season,y.current_season + 1) as current_season
from today t FULL OUTER JOIN yesterday y
ON t.player_name = y.player_name;

with unnested as (
select player_name,
		UNNEST(season_stats) as season_stats
from players where current_season = 2001 and player_name ='Michael Jordan'
				)
select player_name,
		(season_stats::season_stats).*
from unnested;


select * from player_seasons;
select * from players where current_season = 2001;
select * from players where current_season = 2001
and player_name = 'Michael Jordan';

select 
	player_name,
	season_stats[1] as first_season,
	season_stats[CARDINALITY(season_stats)] as last_season
from players
where current_season = 2001;


select 
	player_name,
	(season_stats[CARDINALITY(season_stats)]::season_stats).pts/
	case when (season_stats[1]::season_stats).pts =0 then 1
	   	else (season_stats[1]::season_stats).pts
	end 
	
from players
where current_season = 2001
order by 2 desc;

select * from players;

