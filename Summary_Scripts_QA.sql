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

Results from first part of question selecting duplicates and brining NULL up top.

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

/* Create a temporary table with a new column ID as a row_number on the table after order by contry_code, continent_code*/
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
 
 
Results in Table continent_map:

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
....... etc 


2\. List the countries ranked 10-12 in each continent by the percent of year-over-year growth descending from 2011 to 2012.

The percent of growth should be calculated as: ((2012 gdp - 2011 gdp) / 2011 gdp)

The list should include the columns:

- rank
- continent_name
- country_code
- country_name
- growth_percent

/* in order to do this one I first created a VIEW in my data base which joined the per_capita table to all other tables appropriately. the join looks like this*/

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `braintree`.`gdp_join` AS
    SELECT 
        `braintree`.`per_capita`.`country_code` AS `country_code`,
        `braintree`.`countries`.`country_name` AS `country_name`,
        `braintree`.`continents`.`continent_code` AS `continent_code`,
        `braintree`.`continents`.`continent_name` AS `continent_name`,
        `braintree`.`per_capita`.`year` AS `year`,
        `braintree`.`per_capita`.`gdp_per_capita` AS `gdp_per_capita`
    FROM
        (((`braintree`.`continent_map`
        JOIN `braintree`.`countries` ON ((`braintree`.`continent_map`.`country_code` = `braintree`.`countries`.`country_code`)))
        JOIN `braintree`.`continents` ON ((`braintree`.`continent_map`.`continent_code` = `braintree`.`continents`.`continent_code`)))
        JOIN `braintree`.`per_capita` ON ((`braintree`.`continent_map`.`country_code` = `braintree`.`per_capita`.`country_code`)))
        
        
/* results from the select look like this:*/
country_code      country_name	continent_code	continent_name	year	gdp_per_capita
ABW	Aruba	NA	North America	2004	22566.68216
AND	Andorra	EU	Europe	2004	29372.16674
AFG	Afghanistan	AS	Asia	2004	220.0562878
AGO	Angola	AF	Africa	2004	1229.342988
ALB	Albania	EU	Europe	2004	2320.89233
ARE	United Arab Emirates	AS	Asia	2004	40403.98817
ARG	Argentina	SA	South America	2004	3997.243288
ARM	Armenia	AF	Africa	2004	1182.09736
ATG	Antigua and Barbuda	NA	North America	2004	11076.06362
AUS	Australia	OC	Oceania	2004	30464.00376
..... and on and on

/*Using this view as my dataset to refer to, I'll answer the GDP question with this query:*/

use braintree;

CREATE TABLE gdp_growth_rank (
SELECT 
    t1.continent_name,
    t1.country_code,
    t1.country_name,
    CONCAT(ROUND(((t2.gdp_2012 - t1.gdp_2011) / t1.gdp_2011) * 100,
                    2),
            '%') AS growth_percent
           
           ,RANK() OVER (PARTITION BY t1.continent_name order by ((t2.gdp_2012 - t1.gdp_2011) / t1.gdp_2011) desc)  as drank
FROM
    (SELECT 
        continent_name,
            country_code,
            country_name,
            gdp_per_capita AS 'gdp_2011'
    FROM
        gdp_join
    WHERE
        year = 2011) t1
        INNER JOIN
    (SELECT DISTINCT
        country_code, gdp_per_capita AS 'gdp_2012'
    FROM
        gdp_join
    WHERE
        year = 2012) t2 ON t1.country_code = t2.country_code);

/*after saving the results of our select statement above, query the resulting table to get ranks 10-12 for each continent*/

SELECT * FROM braintree.gdp_growth_rank

where drank > 9 and drank < 13;
        
/* yields these results!*/

rank    continent_name  country_code    country_name    growth_percent
10	Africa	RWA	Rwanda	8.73%
11	Africa	GIN	Guinea	8.32%
12	Africa	NGA	Nigeria	8.09%
10	Asia	UZB	Uzbekistan	11.12%
11	Asia	IRQ	Iraq	10.06%
12	Asia	PHL	Philippines	9.73%
10	Europe	MNE	Montenegro	-2.93%
11	Europe	SWE	Sweden	-3.02%
12	Europe	ISL	Iceland	-3.84%
10	North America	GTM	Guatemala	2.71%
11	North America	HND	Honduras	2.71%
12	North America	ATG	Antigua and Barbuda	2.52%
10	Oceania	FJI	Fiji	3.29%
11	Oceania	TUV	Tuvalu	1.27%
12	Oceania	KIR	Kiribati	0.04%
10	South America	ARG	Argentina	5.67%
11	South America	PRY	Paraguay	-3.62%
12	South America	BRA	Brazil	-9.83%


3\. For the year 2012, create a 3 column, 1 row report showing the percent share of gdp_per_capita for the following regions:

(i) Asia, (ii) Europe, (iii) the Rest of the World. Your result should look something like

 Asia  | Europe | Rest of World 
------ | ------ | -------------
25.0%  | 25.0%  | 50.0%

SELECT 
    CONCAT(ROUND(((SELECT 
                            SUM(gdp_per_capita)
                        FROM
                            braintree.gdp_join
                        WHERE
                            year = 2012 AND continent_name = 'Asia') / (SELECT 
                            SUM(gdp_per_capita)
                        FROM
                            braintree.gdp_join
                        WHERE
                            year = 2012)) * 100,
                    1),
            '%') AS 'Asia',
    CONCAT(ROUND(((SELECT 
                            SUM(gdp_per_capita)
                        FROM
                            braintree.gdp_join
                        WHERE
                            year = 2012
                                AND continent_name = 'Europe') / (SELECT 
                            SUM(gdp_per_capita)
                        FROM
                            braintree.gdp_join
                        WHERE
                            year = 2012)) * 100,
                    1),
            '%') AS 'Europe',
    CONCAT(ROUND(((SELECT 
                            SUM(gdp_per_capita)
                        FROM
                            braintree.gdp_join
                        WHERE
                            year = 2012 AND continent_name != 'Asia'
                                AND continent_name != 'Europe') / (SELECT 
                            SUM(gdp_per_capita)
                        FROM
                            braintree.gdp_join
                        WHERE
                            year = 2012)) * 100,
                    1),
            '%') AS 'Rest of World'

/* Results of This Query Below! */

Asia    Europe  Rest of World
28.3%	42.2%	29.4%

PS:
I have a question to better understand what the question is asking but instead made an assumption and took a sum of each continents GDP per capita instead of any other metric for the sake of time. However this metric is a bit strange but this data needs more information in order to properly answer the question, EG, population of each country in the year 2012 to get GDP of each country. Otherwise, continents with more countries are skewed simply because there are more of them, not necessarily a reflection of true GDP % share.

4a\. What is the count of countries and sum of their related gdp_per_capita values for the year 2007 where the string 'an' (case insensitive) appears anywhere in the country name?

SELECT 
    COUNT(*), SUM(gdp_per_capita)
FROM
    braintree.gdp_join
WHERE
    year = 2007 AND LOWER(country_name) LIKE '%an%';

Result:

count(*)    sum(gdp_per_capita)
58	888339.8619685002

4b\. Repeat question 4a, but this time make the query case sensitive.

SELECT COUNT(*), SUM(gdp_per_capita)
FROM braintree.gdp_join
WHERE year = 2007 AND country_name LIKE BINARY '%an%';

Result:
count(*)    sum(gdp_per_capita)
56	845004.2528505002

5\. Find the sum of gpd_per_capita by year and the count of countries for each year that have non-null gdp_per_capita where (i) the year is before 2012 and (ii) the country has a null gdp_per_capita in 2012. Your result should have the columns:

- year
- country_count
- total


SELECT 
    year, COUNT(DISTINCT (country_name)) as country_count, SUM(gdp_per_capita) as total
FROM
    braintree.gdp_join
WHERE
    country_code IN (SELECT 
            t1.country_code
        FROM
            braintree.countries t1
                LEFT JOIN
            (SELECT 
                *
            FROM
                per_capita
            WHERE
                year = 2012) t2 ON (t1.country_code = t2.country_code)
        WHERE
            year IS NULL)
GROUP BY year;

Result:

year    country_count   total
2004	14	435360.5308659
2005	14	453525.7332075
2006	13	491425.8090778
2007	13	580931.606779
2008	10	574016.20641
2009	8	399526.161602
2010	4	179750.82754000003
2011	4	199152.680469

6\. All in a single query, execute all of the steps below and provide the results as your final answer:

a. create a single list of all per_capita records for year 2009 that includes columns:

- continent_name
- country_code
- country_name
- gdp_per_capita

b. order this list by:

- continent_name ascending
- characters 2 through 4 (inclusive) of the country_name descending


SELECT continent_name, country_code, country_name, gdp_per_capita FROM braintree.gdp_join

where year = 2009

order by continent_name asc, substring(country_name,2,3) desc

Results:
continent_name  country_code   country_name   gdp_per_capita
Africa	SWZ	Swaziland	2693.516041
Africa	RWA	Rwanda	498.8454588
Africa	BDI	Burundi	194.8966661
Africa	BFA	Burkina Faso	553.0423743
Africa	TUN	Tunisia	4177.130224
Africa	GNB	Guinea-Bissau	536.8028066
Africa	GIN	Guinea	435.1756629
Africa	SDN	Sudan	1190.793925
Africa	ETH	Ethiopia	332.0454408
Africa	ARM	Armenia	2913.60061
Africa	ERI	Eritrea	334.0648852
Africa	GNQ	Equatorial Guinea	15300.6997
Africa	MOZ	Mozambique	414.110156
Africa	SSD	South Sudan	1245.038171
Africa	ZAF	South Africa	5654.492378
Africa	BWA	Botswana	5178.439109
Africa	CIV	Cote d'Ivoire	1238.708134
Africa	MAR	Morocco	2861.027067
Africa	COD	Congo, Dem. Rep.	185.2322376
Africa	COG	Congo, Rep.	2401.298155
Africa	COM	Comoros	803.4861078
Africa	TGO	Togo	514.7730045
Africa	AGO	Angola	3988.683557
Africa	DZA	Algeria	3771.284844
Africa	ZWE	Zimbabwe	475.8538049
Africa	NGA	Nigeria	1090.746284
Africa	NER	Niger	352.6851141
Africa	SLE	Sierra Leone	435.109412
Africa	LBY	Libya	10455.57487
Africa	LBR	Liberia	302.2803524
Africa	GHA	Ghana	1096.533657
Africa	TCD	Chad	813.7560302
Africa	EGY	Egypt, Arab Rep.	2461.530857
Africa	UGA	Uganda	451.0815515
Africa	SYC	Seychelles	9707.265361
Africa	LSO	Lesotho	862.7867207
Africa	KEN	Kenya	767.8737535
Africa	CAF	Central African Republic	464.5132313
Africa	BEN	Benin	712.616527
Africa	SEN	Senegal	1017.968601
Africa	MRT	Mauritania	860.9083679
Africa	MUS	Mauritius	6928.972012
Africa	STP	Sao Tome and Principe	1134.113593
Africa	TZA	Tanzania	504.2002377
Africa	NAM	Namibia	4133.058699
Africa	CMR	Cameroon	1102.520394
Africa	ZMB	Zambia	998.4404343
Africa	GMB	Gambia, The	553.0993514
Africa	MLI	Mali	661.1317114
Africa	MWI	Malawi	345.1947614
Africa	MDG	Madagascar	419.0909429
Africa	CPV	Cabo Verde	3524.330353
Africa	GAB	Gabon	7919.710893
Asia	AZE	Azerbaijan	4950.294791
Asia	UZB	Uzbekistan	1181.84736
Asia	KGZ	Kyrgyz Republic	871.2182975
Asia	CYP	Cyprus	29427.90879
Asia	KWT	Kuwait	37160.54324
Asia	RUS	Russian Federation	8615.658757
Asia	TUR	Turkey	8626.398166
Asia	TKM	Turkmenistan	4059.973975
Asia	ISR	Israel	27491.5133
Asia	BRN	Brunei Darussalam	27212.05637
Asia	LKA	Sri Lanka	2057.113672
Asia	IRQ	Iraq	3701.861626
Asia	IRN	Iran, Islamic Rep.	4931.282897

