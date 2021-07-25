drop table if exists dim_mob_organization
select 
	o.organization_name,
	fd.for_division,
	og.*,
	o.country_code,
	o.latitude,
	o.longitude
into dim_mob_organization
from (
	select 
		grid_id,
		for_division_id,
		COUNT(sameInst) as researchers,
		AVG(CAST(sameInst AS FLOAT)) as ResSameInst,
		AVG(CAST(sameCountry AS FLOAT)) as ResSameCountry,
		AVG(CAST(sameCountry AS FLOAT)) - AVG(CAST(sameInst AS FLOAT)) as ResOtherInstSameCountry,
		1 - (AVG(CAST(sameCountry AS FLOAT)) - AVG(CAST(sameInst AS FLOAT))) - AVG(CAST(sameInst AS FLOAT)) as ResOtherCountry
	FROM 
		dim_mob_researchers
	where 
		T > 6
	group by grid_id, for_division_id
	) og
left join dimensions_2019jun..organization o ON o.grid_id = og.grid_id
left join dimensions_2019jun..for_division fd ON fd.for_division_id = og.for_division_id

INSERT INTO dbo.dim_mob_organization (organization_name,for_division,grid_id,for_division_id,researchers,ResSameInst,
									  ResSameCountry,ResOtherInstSameCountry,ResOtherCountry,--shareSameInst,shareSameCountry,
									  country_code,latitude,longitude)
select 
	o.organization_name,
	 'All' as for_division, 
	og.*,
	o.country_code,
	o.latitude,
	o.longitude
from (
	select 
		grid_id,
		NULL as for_division_id,
		COUNT(sameInst) as researchers,
		AVG(CAST(sameInst AS FLOAT)) as ResSameInst,
		AVG(CAST(sameCountry AS FLOAT)) as ResSameCountry,
		AVG(CAST(sameCountry AS FLOAT)) - AVG(CAST(sameInst AS FLOAT)) as ResOtherInstSameCountry,
		1 - (AVG(CAST(sameCountry AS FLOAT)) - AVG(CAST(sameInst AS FLOAT))) - AVG(CAST(sameInst AS FLOAT)) as ResOtherCountry
	FROM 
		dim_mob_researchers
	where 
		T > 6
	group by grid_id
	) og
left join dimensions_2019jun..organization o ON o.grid_id = og.grid_id