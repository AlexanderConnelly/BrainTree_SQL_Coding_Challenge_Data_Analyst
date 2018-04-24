use braintree;


SELECT 
    year, COUNT(DISTINCT (country_name)), SUM(gdp_per_capita)
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
GROUP BY year
;


SELECT t1.country_code FROM braintree.countries t1

left join (select * from per_capita where year = 2012) t2 on (t1.country_code = t2.country_code)

where year is null;




