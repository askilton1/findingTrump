--alter view census_counties as
select d.STATEFIP, d.COUNTY, d.white_percent_in_college_hhold, e.nonwhite_percent_in_college_hhold
from
	(select c.STATEFIP, c.COUNTY, avg(c.hh_College_Degree) [white_percent_in_college_hhold]
	from
		(select a.STATEFIP, a.COUNTY, a.RACE, cast(b.hh_College_Degree as float) [hh_College_Degree]
		from census_clean a
		left outer join census_hhold b
		on a.SERIAL = b.SERIAL) c
	where RACE = 1
	group by c.STATEFIP, c.COUNTY) d
inner join 
	(select c.STATEFIP, c.COUNTY, avg(c.hh_College_Degree) [nonwhite_percent_in_college_hhold]
	from
		(select a.STATEFIP, a.COUNTY, a.RACE, cast(b.hh_College_Degree as float) [hh_College_Degree]
		from census_clean a
		left outer join census_hhold b
		on a.SERIAL = b.SERIAL) c
	where RACE != 1
	group by c.STATEFIP, c.COUNTY) e
on d.STATEFIP = e.STATEFIP and d.COUNTY = e.COUNTY