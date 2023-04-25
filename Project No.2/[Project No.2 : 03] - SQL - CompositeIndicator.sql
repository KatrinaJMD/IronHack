-- 2003 -2018
-- Projetc Week 2 - 

SELECT country, '2003' as year, IFNULL(YR2003,0) as value FROM external_health_expenditure
UNION ALL
SELECT country, '2004' as year, IFNULL(YR2004,0) as value FROM external_health_expenditure
UNION ALL
SELECT country, '2005' as year, IFNULL(YR2005,0) as value FROM external_health_expenditure
UNION ALL
SELECT country, '2006' as year, IFNULL(YR2006,0) as value FROM external_health_expenditure
UNION ALL
SELECT country, '2007' as year, IFNULL(YR2007,0) as value FROM external_health_expenditure
UNION ALL
SELECT country, '2008' as year, IFNULL(YR2008,0) as value FROM external_health_expenditure
UNION ALL
SELECT country, '2009' as year, IFNULL(YR2009,0) as value FROM external_health_expenditure
UNION ALL
SELECT country, '2010' as year, IFNULL(YR2010,0) as value FROM external_health_expenditure
UNION ALL
SELECT country, '2011' as year, IFNULL(YR2011,0) as value FROM external_health_expenditure
UNION ALL
SELECT country, '2012' as year, IFNULL(YR2012,0) as value FROM external_health_expenditure
UNION ALL
SELECT country, '2013' as year, IFNULL(YR2013,0) as value FROM external_health_expenditure
UNION ALL
SELECT country, '2014' as year, IFNULL(YR2014,0) as value FROM external_health_expenditure
UNION ALL
SELECT country, '2015' as year, IFNULL(YR2015,0) as value FROM external_health_expenditure
UNION ALL
SELECT country, '2016' as year, IFNULL(YR2016,0) as value FROM external_health_expenditure
UNION ALL
SELECT country, '2017' as year, IFNULL(YR2017,0) as value FROM external_health_expenditure
UNION ALL
SELECT country, '2018' as year, IFNULL(YR2018,0) as value FROM external_health_expenditure;
