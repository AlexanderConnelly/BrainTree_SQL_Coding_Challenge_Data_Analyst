
use braintree;

CREATE TABLE GDP_Growth_Rank (
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
        year = 2012) t2 ON t1.country_code = t2.country_code)
        
