if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'census_hhold') drop view census_hhold
GO 

create view census_hhold as
	select a.REGION, a.STATEFIP, a.COUNTY, a.METRO, a.HHINCOME, a.AGE, a.RACE, a.white, b.*
		from census_clean a
		inner join household_level b
		on a.SERIAL = b.SERIAL