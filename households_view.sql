create view households as
	select SERIAL,
				  STATEFIP, 
				  COUNTY, 
				  REGION, 
				  METRO, 
				  max(white) [White], --at least one person in household is white
				  avg(HHINCOME) [Household income], 
				  max(college) [College Degree], --at least one person has college degree
				  max(hispanic) [Hispanic] --at least one person in household is hispanic
		from census20_clean
		group by REGION, METRO, STATEFIP, COUNTY, SERIAL