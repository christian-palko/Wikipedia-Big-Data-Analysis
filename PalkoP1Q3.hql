--Question 3

---------------------------------ONLY EXECUTE THESE QUERIES IF YOU DON'T HAVE PRIOR QUESTIONS' STATEMENTS/QUERIES-----------------------------------

CREATE DATABASE Project1DB;
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

--Create clickstream table.
--Load in all pageview data for a full DAY (December 15th, 2020) to represent the MONTH

LOAD DATA LOCAL INPATH '/Users/chrispalko/Project1Files/Question2/Pageviews' 
INTO TABLE pageviews_dec;

CREATE TABLE stream (
	prev STRING,
	curr STRING,
	type_ STRING,
	n INT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';
LOAD DATA LOCAL INPATH '/Users/chrispalko/Project1Files/Question2/Clickstream' 
INTO TABLE stream;

---------------------------------ONLY EXECUTE THESE QUERIES IF YOU DON'T HAVE PRIOR QUESTIONS' STATEMENTS/QUERIES-----------------------------------

USE Project1DB;

--Create a new intermediate pageviews table which doesn't filter out pages with <5000 viewcounts. The likelihood
--of the specific article we are querying being subject to an unusual spike in views on a specific day is low.
--insert only English pageview data and multiply the viewcounts to simulate a month's worth, again to
--match the clickstream data, which is monthly.
CREATE TABLE pageviews_dec_int_Q2 (
	page_title STRING,
	count_views INT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';


INSERT INTO TABLE pageviews_dec_int_Q2 
	(SELECT page_title, ((SUM(count_views)) * 31) AS count_views
	FROM pageviews_dec
	WHERE (domain_code = 'en' OR domain_code = 'en.m')
	GROUP BY page_title
	ORDER BY count_views DESC);

--Find denominator: 
SELECT page_title, count_views
FROM pageviews_dec_int_Q2
WHERE page_title = 'Hotel_California';
--Result: 54064

--Find numerator: 

SELECT curr, SUM(n) AS count_
FROM stream
WHERE prev = 'Hotel_California'
GROUP BY curr
ORDER BY count_ DESC;
--Result: 2371 ("Hotel_California_(Eagles_album)")



--Utilize Create Table As statements:
SET hive.strict.checks.cartesian.product = FALSE;

CREATE TABLE series1 
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ' AS
SELECT a.prev, a.curr, (a.count_ / b.count_views) AS decimal_ FROM
	(SELECT prev, curr, SUM(n) AS count_
	FROM stream
	WHERE prev = 'Hotel_California'
	GROUP BY curr, prev
	ORDER BY count_ DESC) a
INNER JOIN
	(SELECT page_title, count_views
	FROM pageviews_dec_int_Q2
	WHERE page_title = 'Hotel_California') b
ON (a.prev = b.page_title);

--Next in series: 

CREATE TABLE series2 
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ' AS
SELECT a.prev, a.curr, (a.count_ / b.count_views) as decimal_ FROM
	(SELECT prev, curr, SUM(n) AS count_
	FROM stream
	WHERE prev = 'Hotel_California_(Eagles_album)'
	AND curr != 'Hotel_California'
	GROUP BY curr, prev
	ORDER BY count_ DESC) a
INNER JOIN
	(SELECT page_title, count_views
	FROM pageviews_dec_int_Q2
	WHERE page_title = 'Hotel_California_(Eagles_album)') b
ON (a.prev = b.page_title);

--last in series:

CREATE TABLE series3
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ' AS
SELECT a.prev, a.curr, (a.count_ / b.count_views) as decimal_
FROM
	(SELECT prev, curr, SUM(n) AS count_
	FROM stream
	WHERE prev = 'The_Long_Run_(album)'
	GROUP BY curr, prev
	ORDER BY count_ DESC) a
INNER JOIN
	(SELECT page_title, count_views
	FROM pageviews_dec_int_Q2
	WHERE page_title = 'The_Long_Run_(album)') b
ON (a.prev = b.page_title);

SELECT series1.decimal_ * series2.decimal_ * series3.decimal_ * 100 AS percentage
FROM series1 
INNER JOIN series2
ON (series1.curr = series2.prev)
INNER JOIN series3
ON (series2.curr = series3.prev)
LIMIT 1;