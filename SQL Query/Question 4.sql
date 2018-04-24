

/*4a\. What is the count of countries and sum of their related gdp_per_capita values for the year 2007 where the string 'an' (case insensitive) appears anywhere in the country name?
4b\. Repeat question 4a, but this time make the query case sensitive.
*/

/*insensitive*/
SELECT 
    COUNT(*), SUM(gdp_per_capita)
FROM
    braintree.gdp_join
WHERE
    year = 2007 AND country_name LIKE '%an%';

/*sensitive solution*/
SELECT COUNT(*), SUM(gdp_per_capita)
FROM braintree.gdp_join
WHERE year = 2007 AND country_name LIKE BINARY '%an%';



