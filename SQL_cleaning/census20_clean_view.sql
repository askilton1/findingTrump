create view census20_clean
as
	select top 10 RECTYPE, YEAR, DATANUM, SERIAL, PERNUM, REGION, STATEFIP, COUNTY, METRO, HHINCOME, AGE, RACE,
			case 
				when HISPAN > 0 then 1
				else 0
			end 
				as hispanic,
			case
				when EDUC = 11 then 5 -- 5 of more years of college
				when EDUC = 10 then 4 -- four years of college
				when EDUC <= 9 then 3 -- some college
				when EDUC = 6 then 2 -- high school degree
				when EDUC <= 5 then 1 -- less than high school degree
			end 
				as educ,
			case 
				when SEX = 2 then 0
				else 1
			end
				as male
	from census20
