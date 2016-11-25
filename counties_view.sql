--select top 100 * from census20_clean
create view counties as
select top 10 a.STATEFIP, a.COUNTY, a.REGION, a.METRO, avg(white) [Percent White], avg(a.AGE) [Average Age], avg(a.HHINCOME) [Average Household Income], avg(b.hh_college) [Percent College Degree], max(b.hh_hispanic) [Percent Hispanic]
	from census20_clean a
	left outer join ( -- subquery creates household level variables
					 select DATANUM, SERIAL, max(college) [hh_college], max(hispanic) [hh_hispanic]
					 from census20_clean
					 group by DATANUM, SERIAL) b
	on (a.SERIAL = b.SERIAL AND a.DATANUM = b.DATANUM)
	where a.HHINCOME < 2000000 and a.EDUC != 0
	group by a.REGION, a.METRO, a.STATEFIP, a.COUNTY

select top 10 * from counties