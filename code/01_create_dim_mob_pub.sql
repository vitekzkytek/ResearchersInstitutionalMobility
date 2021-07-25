drop table if exists {{target_database}}.dbo.dim_mob_pub
select distinct
	pa.pub_id,
	pa.author_id,
	pa.researcher_id,
	paf.grid_id,
	o.country_code,
	p.pub_year,
	pd.for_division_id,
	RANK() over (partition by pa.researcher_id order by p.pub_year ASC) as N,
	p.pub_year - FIRST_VALUE(p.pub_year) over (partition by pa.researcher_id order by p.pub_year ASC) as T
into {{target_database}}.dbo.dim_mob_pub
from {{dimensions_database}}..pub_author_affiliation paa
left join {{dimensions_database}}..pub_author pa on paa.pub_id = pa.pub_id and paa.author_seq = pa.author_seq
left join {{dimensions_database}}..pub_affiliation paf on paa.pub_id = paf.pub_id and paa.affiliation_seq = paf.affiliation_seq
left join {{dimensions_database}}..pub p on p.pub_id = paa.pub_id
right join {{dimensions_database}}..pub_for_division pd on paa.pub_id = pd.pub_id
left join {{dimensions_database}}..organization o on paf.grid_id = o.grid_id
where pub_year < 2019

create index idx_dim_mob_pub on dim_mob_pub(researcher_id,grid_id,pub_year,for_division_id)