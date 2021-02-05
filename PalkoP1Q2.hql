--Question 2


---------------------------------ONLY EXECUTE THESE QUERIES IF YOU DON'T HAVE PRIOR QUESTIONS' STATEMENTS/QUERIES-----------------------------------

CREATE DATABASE Project1DB;

---------------------------------ONLY EXECUTE THESE QUERIES IF YOU DON'T HAVE PRIOR QUESTIONS' STATEMENTS/QUERIES-----------------------------------
USE Project1DB;

--Create a December pageviews table 

CREATE TABLE pageviews_dec (
	domain_code STRING, 
	page_title STRING,
	count_views INT,
	total_response_size INT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' '
TBLPROPERTIES("skip.header.line.count"="1");

--Load in all pageview data for a full DAY (December 15th, 2020) to represent the MONTH
TRUNCATE TABLE pageviews_dec;
LOAD DATA LOCAL INPATH '/Users/chrispalko/Project1Files/Question2/Pageviews' 
INTO TABLE pageviews_dec;

--Create an intermediate table with only relevant columns (page_title, count_views) 
--from pageviews_dec:

CREATE TABLE pageviews_dec_int (
	page_title STRING,
	count_views INT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

--Insert pageviews_dec data into pageviews_dec_int
--Filter out non-english results
--Multiply views per page by 30 to simulate a full month vs 1 day. (hardware limitation; 
--full month is 100s of GBs):

INSERT INTO TABLE pageviews_dec_int 
	(SELECT page_title, ((SUM(count_views)) * 31) AS count_views
	FROM pageviews_dec
	WHERE (domain_code = 'en' OR domain_code = 'en.m')
	AND count_views > 5000
	GROUP BY page_title
	ORDER BY count_views DESC);

--Create clickstream table, loading all English clickstreams from the whole month of December

CREATE TABLE stream (
	prev STRING,
	curr STRING,
	type_ STRING,
	n INT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';
LOAD DATA LOCAL INPATH '/Users/chrispalko/Project1Files/Question2/Clickstream' 
INTO TABLE stream;

--Create intermediate clickstream table ordered by highest views to lowest 
--since we'll be omitting low-view join results anyway, no reason to mapreduce through them. 
--Group by prev and sum n to reduce workload in join. Don't include irrelevant "curr" field.

CREATE TABLE stream_int (
	prev STRING,
	n INT
) 
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

INSERT INTO TABLE stream_int
	SELECT prev, SUM(n) as count_stream
	FROM stream
	WHERE type_ = 'link'
	GROUP BY prev
	ORDER BY count_stream DESC;

SELECT * FROM stream_int;


--Select PAGE TITLE, and (LINKS CLICKED from that page /ALL VIEWS of that page)--> (primary question being asked)

SELECT a.page_title, (b.n / a.count_views_sum) AS fraction FROM
	(SELECT page_title, SUM(count_views) as count_views_sum
	FROM pageviews_dec_int
	GROUP BY page_title) a
INNER JOIN
	(SELECT prev, n
	FROM stream_int) b 
ON (a.page_title = b.prev)
ORDER BY fraction DESC;