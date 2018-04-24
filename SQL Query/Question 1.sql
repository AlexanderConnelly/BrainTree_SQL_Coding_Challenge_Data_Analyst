/*Data Integrity Checking & Cleanup

- Alphabetically list all of the country codes in the continent_map table that appear more than once. Display any values where country_code is null as country_code = "FOO" and make this row appear first in the list, even though it should alphabetically sort to the middle. Provide the results of this query as your answer.

- For all countries that have multiple rows in the continent_map table, delete all multiple records leaving only the 1 record per country. The record that you keep should be the first one when sorted by the continent_code alphabetically ascending. Provide the query/ies and explanation of step(s) that you follow to delete these records.
*/
CREATE DATABASE BrainTree

CREATE TABLE `braintree`.`continent_map` (`country_code` text, `continent_code` text);
PREPARE stmt FROM 'INSERT INTO `braintree`.`continent_map` (`continent_code`,`country_code`) VALUES(?,?)'
DEALLOCATE PREPARE stmt

CREATE TABLE `braintree`.`continents` (`continent_code` text, `continent_name` text)
PREPARE stmt FROM 'INSERT INTO `braintree`.`continents` (`continent_name`,`continent_code`) VALUES(?,?)'
DEALLOCATE PREPARE stmt

CREATE TABLE `braintree`.`countries` (`country_code` text, `country_name` text)
PREPARE stmt FROM 'INSERT INTO `braintree`.`countries` (`country_name`,`country_code`) VALUES(?,?)'
DEALLOCATE PREPARE stmt

CREATE TABLE `braintree`.`per_capita` (`country_code` text, `year` int, `gdp_per_capita` double)
PREPARE stmt FROM 'INSERT INTO `braintree`.`per_capita` (`gdp_per_capita`,`country_code`,`year`) VALUES(?,?,?)'
DEALLOCATE PREPARE stmt

/* Replace '' empty strings with NULL*/
USE braintree;
UPDATE continent_map
    
SET
    country_code = CASE country_code WHEN '' THEN NULL ELSE country_code END,
    continent_code = CASE continent_code WHEN '' THEN NULL ELSE continent_code END;

/* Select Statement To Pull Up Duplicate Country Codes, FOO on top*/
SELECT 
    COALESCE(country_code, 'FOO')
FROM
    braintree.continent_map
GROUP BY country_code
HAVING COUNT(*) > 1
ORDER BY country_code;

/*Results from first part of question selecting duplicates and brining NULL up top.

country_code:
FOO
ARM
AZE
CYP
GEO
KAZ
RUS
TUR
UMI

Part 2:

 Create a temporary table with a new column ID as a row_number on the table after order by contry_code, continent_code*/
 CREATE TABLE t1 (
 SELECT row_number() over (order by country_code, continent_code asc) as 'ID',country_code
      ,continent_code
  FROM braintree.continent_map );
CREATE TABLE t2 (Select MIN(ID) as ID from t1 group by country_code );
 
/*Delete the rows that dont have a min ID number after group by country_code*/
Delete From t1 where ID NOT IN(select ID from t2) ;

/*Reset continent_map table*/
Delete From continent_map;

/*Refill continent_map from temp_table*/
insert into continent_map
  select country_code, continent_code from t1;
 
 /*drop temporary tables*/
 DROP TABLE t1;
 DROP TABLE t2;
 
 
/*Results in Table continent_map:

country_code	continent_code
NULL	AS
ABW	NA
AFG	AS
AGO	AF
AIA	NA
ALA	EU
ALB	EU
AND	EU
ANT	NA
ARE	AS
ARG	SA
ARM	AF
ASM	OC
....... etc */