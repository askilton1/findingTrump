select a.YEAR, a.DATANUM, a.SERIAL, a.STATEFIP, a.COUNTY, a.REGION, a.METRO, a.RACE, a.AGE, a.HHINCOME, b.hheduc 
	from dbo.census20 a
	left outer join (
					 select YEAR, DATANUM, SERIAL, max(EDUC) as hheduc, max(HISPAN) as hispanic
					 from dbo.census20  
					 group by YEAR, DATANUM, SERIAL) b
	on (a.SERIAL = b.SERIAL AND a.YEAR = b.YEAR AND a.DATANUM = b.DATANUM)
	where a.HHINCOME < 2000000 and a.EDUC != 0