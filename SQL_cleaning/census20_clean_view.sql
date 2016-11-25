alter view census_2013_5year_clean
as
	select RECTYPE, DATANUM, SERIAL, RELATE, PERNUM, REGION, STATEFIP, COUNTY, METRO, HHINCOME, AGE, RACE,
			case 
				when HISPAN > 0 then 1
				else 0
			end  as hispanic,
			case
				when EDUC = 11 then 5 -- 5 of more years of college
				when EDUC = 10 then 4 -- four years of college
				when EDUC <= 9 then 3 -- some college
				when EDUC = 6 then 2 -- high school degree
				when EDUC <= 5 then 1 -- less than high school degree
			end as educ,
			case 
				when EDUC >= 6 then 1
				else 0
			end as college,
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
			end as female_head
	from census_2013_5year
