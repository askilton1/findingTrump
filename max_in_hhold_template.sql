select top 100 * from census20_clean

select top 10 a.YEAR, a.DATANUM, a.SERIAL, a.STATEFIP, a.COUNTY, a.REGION, a.METRO, a.RACE, a.AGE, a.HHINCOME, b.hh_educ, b.hh_hispanic
	from dbo.census20_clean a
	left outer join (
					 select YEAR, DATANUM, SERIAL, max(educ) as hh_educ, max(hispanic) as hh_hispanic
					 from dbo.census20_clean
					 group by YEAR, DATANUM, SERIAL) b
	on (a.SERIAL = b.SERIAL AND a.YEAR = b.YEAR AND a.DATANUM = b.DATANUM)
	where a.HHINCOME < 2000000 and a.EDUC != 0