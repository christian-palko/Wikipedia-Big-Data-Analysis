
# Wikipedia Big Data Analysis

Project 1's analysis consists of using big data tools to answer questions about datasets from Wikipedia. There are a series of basic analysis questions, answered using Hive or MapReduce. The tool(s) used are determined based on the context for each question. The output of the analysis includes MapReduce jarfiles and/or .hql files so that the analysis is a repeatable process that works on a larger dataset, not just an ad hoc calculation. Assumptions and simplfications are required in order to answer these questions, and the final presentation of results includes a discussion of those assumptions/simplifications and the reasoning behind them. In addition to answers and explanations, this project requires a discussion of any intermediate datasets and the reproduceable process used to construct those datasets. Finally, in addition to code outputs, this project requires a simple slide deck providing an overview of results. 

### The questions follow: 
1. Which English wikipedia article got the most traffic on October 20, 2020? 
2. What English wikipedia article has the largest fraction of its readers follow an internal link to another wikipedia article? 
3. What series of wikipedia articles, starting with Hotel California, keeps the largest fraction of its readers clicking on internal links? 
4. Find an example of an English wikipedia article that is relatively more popular in the UK, then find the same for the US and Australia. 
5. How many users will see the average vandalized wikipedia page before the offending edit is reversed? 6. Run an analysis you find interesting on the wikipedia datasets we're using.

# Environment / Technologies 
 Hive, HDFS, YARN, MapReduce
 
# Roles / Responsibilities 
* Created managed Hive tables, loading in local sampled data for specific querying.
* Created intermediate tables for optimization and clarity of code.
* Developed advanced queries containing sub-queries, joins, 'create table as', pattern matching, and aggregate & scalar functions
* Ran Hadoop MapReduce jobs on a single-node cluster through Hive queries, leveraging HDFS and YARN.
* Analyzed queried, sampled data to attempt to extract insight and meaning, while recognizing shortcomings, assumptions, and caveats.

# Run the analyses yourself
To set this up for yourself, you will need to have HDFS, YARN, and Hive on your system. The queries necessary to construct a managed database, tables, and to query from the data, are all contained in order within the respective HQL files. You can download a sample of your choosing from the vast datasets below:


#### Pageviews Filtered to Human Traffic
https://wikitech.wikimedia.org/wiki/Analytics/Data_Lake/Traffic/Pageviews
#### Page Revision and User History
https://wikitech.wikimedia.org/wiki/Analytics/Data_Lake/Edits/Mediawiki_history_dumps#Technical_Documentation
#### Monthly Clickstream
https://meta.wikimedia.org/wiki/Research:Wikipedia_clickstream

##

Includes the presentation with graphical references, step-by-step, alongside the six HQL scripts to recreate the analyses.
