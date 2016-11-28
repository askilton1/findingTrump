create view census_hhold as
	select a.REGION, a.STATEFIP, a.COUNTY, a.METRO, a.HHINCOME, a.AGE, a.RACE, b.*
		from census_2013_5year_clean a
		inner join
			(select 
			    SERIAL,
				max(white) [hh_White], --at least one person in household is white
				max(high_school_degree) [hh_High_School_Degree], --at least one person has college degree
				max(college) [hh_College_Degree], --at least one person has college degree
				max(hispanic) [hh_Hispanic], --at least one person in household is hispanic
				max(female_head) [hh_Female_Head_of_Household], --"head of household" is female
				max(PERNUM) [hh_size],
				sum(in_labor_force) [hh_labor_force],
				sum(adult_men_not_in_labor_force) [hh_adult_men_not_in_labor_force]
			 from census_2013_5year_clean
			 group by SERIAL) b
			 on a.SERIAL = b.SERIAL