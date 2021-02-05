---------------------------------ONLY EXECUTE THESE QUERIES IF YOU DON'T HAVE PRIOR QUESTIONS' STATEMENTS/QUERIES-----------------------------------

CREATE DATABASE Project1DB;

CREATE TABLE pageviews (
	domain_code STRING, 
	page_title STRING,
	count_views INT,
	total_response_size INT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' '
TBLPROPERTIES("skip.header.line.count"="1");
LOAD DATA LOCAL INPATH '/Users/chrispalko/Project1Files/Question1/' INTO TABLE pageviews;

---------------------------------ONLY EXECUTE THESE QUERIES IF YOU DON'T HAVE PRIOR QUESTIONS' STATEMENTS/QUERIES-----------------------------------

USE Project1DB;

CREATE TABLE top_by_domain(
	domain_code STRING, 
	count_views INT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

INSERT INTO TABLE top_by_domain
SELECT domain_code, SUM(count_views)
FROM pageviews
WHERE domain_code NOT LIKE '%en%'
GROUP BY domain_code;

SELECT * FROM top_by_domain ORDER BY count_views desc LIMIT 5;