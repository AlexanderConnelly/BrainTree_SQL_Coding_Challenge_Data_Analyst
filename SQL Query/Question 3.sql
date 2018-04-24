SELECT continent_name, sum(gdp_per_capita) FROM braintree.gdp_join

where year = 2012

group by continent_name;

/*3\. For the year 2012, create a 3 column, 1 row report showing the percent share of gdp_per_capita for the following regions:

(i) Asia, (ii) Europe, (iii) the Rest of the World. Your result should look something like

 Asia  | Europe | Rest of World 
------ | ------ | -------------
25.0%  | 25.0%  | 50.0%*/


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
            
            