--create view census_counties as
select a.*, d.white_percent_in_college_hhold, e.nonwhite_percent_in_college_hhold
from election_data a
inner join 
	(select c.STATEFIP, c.COUNTY, avg(c.white_hh_College_Degree) [white_percent_in_college_hhold]
	from
		(select a.STATEFIP, a.COUNTY, RACE, cast(b.hh_College_Degree as float) [white_hh_College_Degree]
		from census_2013_5year_clean a
		left outer join census_hhold b
		on a.SERIAL = b.SERIAL) c
	where RACE = 1
	group by c.STATEFIP, c.COUNTY) d
on a.STATEFIPS = d.STATEFIP and a.COUNTY = d.COUNTY
inner join 
	(select c.STATEFIP, c.COUNTY, avg(c.nonwhite_hh_College_Degree) [nonwhite_percent_in_college_hhold]
	from
		(select a.STATEFIP, a.COUNTY, RACE, cast(b.hh_College_Degree as float) [nonwhite_hh_College_Degree]
		from census_2013_5year_clean a
		left outer join census_hhold b
		on a.SERIAL = b.SERIAL) c
	where RACE != 1
	group by c.STATEFIP, c.COUNTY) e
on e.STATEFIP = d.STATEFIP and e.COUNTY = d.COUNTY