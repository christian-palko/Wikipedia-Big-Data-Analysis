--Question 1


CREATE DATABASE Project1DB;
USE Project1DB;

CREATE TABLE pageviews (
	domain_code STRING, 
	page_title STRING,
	count_views INT,
	total_response_size INT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' '
TBLPROPERTIES("skip.header.line.count"="1");
LOAD DATA LOCAL INPATH '/Users/chrispalko/Project1Files/Question1/' INTO TABLE pageviews;

SELECT page_title, SUM(count_views) AS eng_views
FROM pageviews
WHERE (domain_code = 'en' OR domain_code = 'en.m')
AND page_title != 'Special:Search'
AND page_title != 'Main_Page'
AND page_title != '-'
GROUP BY page_title
ORDER BY eng_views DESC
LIMIT 10;
