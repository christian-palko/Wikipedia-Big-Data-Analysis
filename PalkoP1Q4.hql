--Question 4


---------------------------------ONLY EXECUTE THESE QUERIES IF YOU DON'T HAVE PRIOR QUESTIONS' STATEMENTS/QUERIES-----------------------------------

CREATE DATABASE Project1DB;

---------------------------------ONLY EXECUTE THESE QUERIES IF YOU DON'T HAVE PRIOR QUESTIONS' STATEMENTS/QUERIES-----------------------------------


USE Project1DB;

--Create a "U.S." pageviews table and insert relevant files
DROP TABLE pageviews_us;
CREATE TABLE pageviews_us (
	domain_code STRING, 
	page_title STRING,
	count_views INT,
	total_response_size INT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' '
TBLPROPERTIES("skip.header.line.count"="1");

LOAD DATA LOCAL INPATH '/Users/chrispalko/Project1Files/Question4/us' 
INTO TABLE pageviews_us;

--Create an intermediate table. Don't include irrelevant columns.
DROP TABLE views_int_us;
CREATE TABLE views_int_us (
page_title STRING,
count_views INT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

INSERT INTO views_int_us
SELECT page_title, SUM(count_views) AS count_views
FROM pageviews_us
WHERE (domain_code = 'en' OR domain_code = 'en.m')
GROUP BY page_title;

--Create a "non-US" pageviews table and insert relevant files
TRUNCATE TABLE pageviews_non;
CREATE TABLE pageviews_non (
	domain_code STRING, 
	page_title STRING,
	count_views INT,
	total_response_size INT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' '
TBLPROPERTIES("skip.header.line.count"="1");

LOAD DATA LOCAL INPATH '/Users/chrispalko/Project1Files/Question4/non' 
INTO TABLE pageviews_non;

--Create another intermediate table

CREATE TABLE views_int_non (
page_title STRING,
count_views INT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

INSERT INTO views_int_non
SELECT page_title, SUM(count_views) AS count_views
FROM pageviews_non
WHERE (domain_code = 'en' OR domain_code = 'en.m')
GROUP BY page_title;

--Next steps: full outer join tables on page_titles, divide non-US by US views
TRUNCATE TABLE join_views;
CREATE TABLE join_views (
page_title STRING,
count_views_us INT,
count_views_non INT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

INSERT INTO join_views
 (SELECT views_int_us.page_title, views_int_us.count_views, views_int_non.count_views
 FROM views_int_us
 LEFT OUTER JOIN views_int_non
 ON (views_int_us.page_title = views_int_non.page_title));

SELECT page_title, 
COALESCE(count_views_us,CAST(0 AS BIGINT)) AS us_views, 
COALESCE(count_views_non,CAST(0 AS BIGINT)) AS non_us_views,
ROUND((COALESCE(count_views_us,CAST(0 AS BIGINT)) / COALESCE(count_views_non,CAST(0 AS BIGINT))),2) 
AS times_more_popular
FROM join_views
ORDER BY times_more_popular DESC;
 