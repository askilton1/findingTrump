--create view census_counties as
select a.STATEFIP, a.COUNTY, a.percent_white_hholds_college, b.percent_black_hholds_college
	from (select STATEFIP, COUNTY, avg(cast(hh_College_Degree as float)) [percent_white_hholds_college]
		  from census_hhold
		  where RACE = 1 and STATEFIP < 10
		  group by STATEFIP, COUNTY) a
	inner join 
		(select STATEFIP, COUNTY, avg(cast(hh_College_Degree as float)) [percent_black_hholds_college] 
			from census_hhold
			where RACE = 2 and STATEFIP < 10
			group by STATEFIP, COUNTY) b
	on a.STATEFIP = b.STATEFIP and a.COUNTY = b.COUNTY
