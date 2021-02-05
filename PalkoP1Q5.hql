---------------------------------ONLY EXECUTE THESE QUERIES IF YOU DON'T HAVE PRIOR QUESTIONS' STATEMENTS/QUERIES-----------------------------------

CREATE DATABASE Project1DB;

---------------------------------ONLY EXECUTE THESE QUERIES IF YOU DON'T HAVE PRIOR QUESTIONS' STATEMENTS/QUERIES-----------------------------------

USE Project1DB;

CREATE TABLE pageviews_dec_rev (
	domain_code STRING, 
	page_title STRING,
	count_views INT,
	total_response_size INT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' '
TBLPROPERTIES("skip.header.line.count"="1");
LOAD DATA LOCAL INPATH '/Users/chrispalko/Project1Files/Question1' 
INTO TABLE pageviews_dec_rev;

CREATE TABLE rev_views (
	page_title STRING,
	views_per_hour INT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';

INSERT INTO TABLE rev_views
SELECT page_title, (SUM(count_views) / 24) FROM pageviews_dec_rev
WHERE page_title != 'Special:Search'
AND page_title != 'Main_Page'
AND page_title != '-'
GROUP BY page_title;

--create revisions table for identifying vandalism
CREATE TABLE rev_van (
	wiki_db STRING,
	event_entity STRING,
	event_type STRING,
	event_timestamp STRING,
	event_comment STRING,
	event_user_id INT,
	event_user_text_historical STRING,
	event_user_text STRING,
	event_user_blocks_historical STRING,
	event_user_blocks STRING,
	event_user_groups_historical STRING,
	event_user_groups STRING,
	event_user_is_bot_by_historical STRING,
	event_user_is_bot_by STRING,
	event_user_is_created_by_self BOOLEAN,
	event_user_is_created_by_system BOOLEAN,
	event_user_is_created_by_peer BOOLEAN,
	event_user_is_anonymous BOOLEAN, 
	event_user_registration_timestamp STRING,
	event_user_creation_timestamp STRING,
	event_user_first_edit_timestamp STRING,
	event_user_revision_count INT,
	event_user_seconds_since_previous_revision INT,
	page_id INT,
	page_title_historical  STRING,
	page_title  STRING,
	page_namespace_historical INT,
	page_namespace_is_content_historical BOOLEAN,
	page_namespace INT,
	page_namespace_is_content BOOLEAN,
	page_is_redirect BOOLEAN,
	page_is_deleted BOOLEAN,
	page_creation_timestamp STRING,
	page_first_edit_timestamp STRING,
	page_revision_count INT,
	page_seconds_since_previous_revision INT,
	user_id INT,
	user_text_historical string,	
	user_text	string,
	user_blocks_historical string,
	user_blocks	string,	
	user_groups_historical	string,	
	user_groups	string,
	user_is_bot_by_historical string,	
	user_is_bot_by	string,	
	user_is_created_by_self boolean,	
	user_is_created_by_system boolean,
	user_is_created_by_peer boolean,
	user_is_anonymous boolean,
	user_registration_timestamp	string,
	user_creation_timestamp	string,
	user_first_edit_timestamp	string,
	revision_id INT,
	revision_parent_id INT, 
	revision_minor_edit boolean, 
	revision_deleted_parts	string,
	revision_deleted_parts_are_suppressed boolean,
	revision_text_bytes INT, 
	revision_text_bytes_diff INT, 
	revision_text_sha1	string,
	revision_content_model	string, 
	revision_content_format	string, 
	revision_is_deleted_by_page_deletion boolean,	
	revision_deleted_by_page_deletion_timestamp	string, 
	revision_is_identity_reverted boolean,
	revision_first_identity_reverting_revision_id INT,
	revision_seconds_to_identity_revert INT,
	revision_is_identity_revert boolean,
	revision_is_from_before_page_creation boolean,
	revision_tags	string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

LOAD DATA LOCAL INPATH '/Users/chrispalko/Project1Files/Question5' 
INTO TABLE rev_van;

--Create intermediate table for revision-vandalism table

CREATE TABLE rev_int (
	page_title STRING,
	avg_hour_to_revert_vandalism FLOAT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

INSERT INTO TABLE rev_int
SELECT
page_title,
ROUND(COALESCE((AVG(revision_seconds_to_identity_revert)),CAST(0 AS BIGINT)) / 3600,2)
FROM rev_van
WHERE (event_entity = 'revision')
AND revision_is_identity_revert = true
AND revision_seconds_to_identity_revert != 0
AND (event_comment LIKE '%vandal%' 
OR event_comment LIKE '%abuse%'
OR event_comment LIKE '%Vandal%'
OR event_comment LIKE '%Abuse%')
GROUP BY page_title;

-- need to now join views table and revision table in new table

CREATE TABLE views_and_rev 
    ROW FORMAT DELIMITED 
    FIELDS TERMINATED by '\t' 
AS 
SELECT rev_views.page_title, rev_views.views_per_hour, rev_int.avg_hour_to_revert_vandalism
FROM rev_views
INNER JOIN rev_int
ON(rev_views.page_title = rev_int.page_title)
ORDER BY avg_hour_to_revert_vandalism DESC;


SELECT 
AVG(avg_hour_to_revert_vandalism) 
AS avg_num_hours_to_revert_vandalism,
(AVG(views_per_hour) / AVG(avg_hour_to_revert_vandalism))
AS avg_views_of_vandalism_per_hour,
(AVG(views_per_hour)) - ((AVG(views_per_hour) / AVG(avg_hour_to_revert_vandalism)))
AS num_user_see_before_revert_per_article_avg
FROM views_and_rev;




