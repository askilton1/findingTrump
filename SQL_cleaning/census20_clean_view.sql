if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'census_clean') drop view census_clean
GO 

create view census_clean
as
	select RECTYPE, DATANUM, SERIAL, RELATE, PERNUM, REGION, METRO, HHINCOME, AGE, RACE, STATEFIP,
			COUNTY / 10 [COUNTY],
			case 
				when HISPAN > 0 then 1
				else 0
			end as hispanic,
			case
				when EDUC = 11 then 5 -- 5 of more years of college
				when EDUC = 10 then 4 -- four years of college
				when EDUC <= 9 then 3 -- some college
				when EDUC = 6 then 2 -- high school degree
				when EDUC <= 5 then 1 -- less than high school degree
			end as educ,
			case 
				when EDUC >= 10 then 1
				else 0
			end as college,
			case 
				when EDUC >= 6 then 1
				else 0
			end as high_school_degree,
			case 
				when SEX = 2 then 0
				else 1
			end as male,
			case
				when RACE = 1 then 1
				else 0
			end as white,
			case
				when SEX = 2 and RELATE = 1 then 1
				else 0
			end as female_head,
			case
				when EMPSTAT != 3 then 1
				else 0
			end as in_labor_force,
			case
				when EMPSTAT = 3 and SEX = 1 and AGE >= 18 then 1
				else 0 
			end as adult_men_not_in_labor_force
	from census
