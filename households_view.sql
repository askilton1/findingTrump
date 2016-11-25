alter view household_level_variables as
	select a.REGION, a.STATEFIP, a.COUNTY, a.METRO, a.HHINCOME, a.AGE, a.RACE, b.*
		from census_2013_5year_clean a
		inner join
			(select 
				SERIAL,
				max(white) [hh_White], --at least one person in household is white
				max(college) [hh_College_Degree], --at least one person has college degree
				max(hispanic) [hh_Hispanic], --at least one person in household is hispanic
				max(female_head) [hh_Female_Head_of_Household], --"head of household" is female
				max(PERNUM) [people_in_household]
			 from census_2013_5year_clean
			 group by SERIAL) b
			 on a.SERIAL = b.SERIAL