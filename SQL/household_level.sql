if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'household_level') drop table household_level
GO 

select 
	SERIAL,
	max(white) [hh_White], --at least one person in household is white
	max(high_school_degree) [hh_High_School_Degree], --at least one person has college degree
	max(college) [hh_College_Degree], --at least one person has college degree
	max(hispanic) [hh_Hispanic], --at least one person in household is hispanic
	max(female_head) [hh_Female_Head_of_Household], --"head of household" is female
	max(PERNUM) [hh_size],
	max(employed) [hh_employed] -- at least one person in household is employed
into household_level
from census_clean
group by SERIAL
