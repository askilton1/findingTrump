select top 10 RECTYPE, YEAR, DATANUM, SERIAL, NUMPREC, REGION, STATEFIP, COUNTY, METRO, HHINCOME, PERNUM, SEX, AGE, RACE, HISPAN = 
	case 
		when HISPAN > 0 then 1
		else 0
	end
	, HISPAND, BPL, CITIZEN, EDUC = 
	case
		when EDUC = 11 then 5 -- 5 of more years of college
		when EDUC = 10 then 4 -- four years of college
		when EDUC <= 9 then 3 -- some college
		when EDUC = 6 then 2 -- high school degree
		when EDUC <= 5 then 1 -- less than high school degree
		end
		, EMPSTAT
from census20
