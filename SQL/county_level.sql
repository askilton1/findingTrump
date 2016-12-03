IF exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'county_level') DROP TABLE county_level
GO 

SELECT a.STATEFIP, a.COUNTY, a.[0] [nonwhite_college_hh], a.[1] [white_college_hh], b.[0] [nonwhite_emp_hh], b.[1] [white_emp_hh]
INTO county_level
FROM (select * from
		(SELECT STATEFIP, COUNTY, white, CAST(hh_College_Degree AS float) as hh_College_Degree
		FROM census_hhold) a
		PIVOT(
		AVG(hh_College_Degree)
		FOR white IN ([0], [1])
		) AS PivotTable) a
INNER JOIN(
	SELECT *
	FROM(
		SELECT STATEFIP, COUNTY, white, CAST(hh_employed AS float) as hh_employed
		FROM census_hhold) a
		PIVOT(
		AVG(hh_employed) 
		FOR white IN ([0], [1])
		) AS PivotTable
		) b
on a.STATEFIP = b.STATEFIP and a.COUNTY = b.COUNTY