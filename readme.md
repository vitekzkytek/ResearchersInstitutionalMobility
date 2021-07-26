# Researchers’ institutional mobility: bibliometric evidence on academic inbreeding and internationalization

paper by: Vít Macháček, Martin Srholec, Márcia R. Ferreira, Nicolas Robinson-Garcia, Rodrigo Costas

see the [paper](add link when available)

This repository contains:

1. Public dataset
2. Source codes for generating the data
3. Jupyter Notebook with figures and tables

## Public dataset
Dataset is available in `./data/dataset_public.csv`. It contains institutional estimates on both the aggregate level and individual disciplines

The following columns are available in the CSV file:

* organization_name - Organization name by GRID
* discipline_name - Discipline name (FoR - division level)
* grid_id - ID from the GRID database
* discipline_id - Discipline ID
* number_researchers - number of researchers identified on the organization in 2018
* pct_insiders - percentage share of insiders (0-100)
* pct_domesticoutsiders - percentage share of domestic outsiders
* pct_foreignoutsiders - percentage share of foreign outsiders
* grid_country_code - organization country (by GRID)
* established_year - year of establishment (by GRID)
* country_name 
* geo_region - geographic region
* latitude - GPS coordinates from GRID
* longitude - GPS coordinates from GRID
* continent

## Source codes for generating the dataset

Prerequisities:
* Access to the Dimensions dump in SQL-like database. Use your DB query editor to run SQL procedures and store the `DB_CONNECTION_STRING` in the `.env` file in the root directory, so that Python can access it.

*Dataset Generation procedure:*

1. ### Generate publication-author-discipline grid table (SQL):

* Excluding publications from 2019 and later.
* Result table `dbo.dim_mob_pub`
* Main logic in `./code/01_create_dim_mob_pub.sql`
* The computation lasts approx. 30 minutes

Creates a table where each row is a unique author-paper-discipline combination.

| column          | description                                                         |
|-----------------|---------------------------------------------------------------------|
| pub_id          | publication_id                                                      |
| researcher_id   | Resarcher ID after disambiguation (main ID)                         |
| for_division_id | Discipline identifier from Fields Of Research (level 2 - Divisions) |
| author_id       | Author ID (before author disambiguation; not used)                  |
| grid_id         | Institution ID from GRID database                                   |
| country_code    | Organization country                                                |
| pub_year        | Publication year                                                    |
| N               | The order of researchers' publication (sorted by pub_year)          |
| T               | Years from the first researchers' publication                       |

SQL code to generate the table is [here](./code/01_create_dim_mob_pub.sql). Replace the {{dimensions_database}} and {{target_database}} placeholders. Works in MSSQL dialect.

2. ### Generate a researcher-level table (Python)

Table where each row is a unique researcher-2018_institution-discipline combination. I.e. multiply affiliated researchers in 2018 will be represented mutliple times. 

* Result table `dbo.dim_mob_researchers`
* Main logic in `./code/create_dim_mob_researchers.ipynb` notebook
* This procedure took a bit longer, but it was over-night

**Procedure**

1. Select all organizations with more than 100 researchers in 2018 (from table organization) - 5902 organizations with unique grid_id

2. Load discipline data from table for_division

3. Iterate over all organizations and all disciplines: 

    a. select all publications of researchers active on the organization in 2018 (see SQL query in Python code) from the dim_mob_pub 

    b. Group by researcher_id and apply function getResearcherMobility on all 

    c. writes results into SQL dim_mob_researchers

Mind that if researcher published in multiple disciplines in 2018 he will be calculated multiple times

Following attributes are available in researchers' table:

| column           | description                                                  |
|------------------|--------------------------------------------------------------|
| grid_id          | Grid ID of 2018 affiliated university                         |
| country_code     | 2018 affiliated university country                           |
| for_division_id  | Discipline ID (if applicable)                                |
| researcher_id    | ID of a single researcher                                    |
| N                | number of researchers' paper (in given field; if applicable) |
| T                | Years since first publication in 2018                        |
| sameInst         | Is `grid_id` listed in the researchers' starting papers?     |
| sameCountry      | Is `country_code` listed in researchers' starting papers?    |

Jupyter Notebook to generate [researchers](./code/02_GenerateDimMobResearcers.ipynb).


### 3. Scaling-up to organizations and disciplines

* Result in `dbo.dim_mob_organizations`
* Main logic in `./code/create_dim_mob_organization.sql`
* <30 seconds
* Two queries: 
    
    a) Average indicator per organization and field of research 
    
    b) Average indicator per organization (for == 'All') - Beware researchers assigned to multiple discipline are counted mutliple times!

| column                  | description                                                                                                      |
|-------------------------|------------------------------------------------------------------------------------------------------------------|
| grid_id                 | GRID institution ID                                                                                              |
| for_division_id         | Field of Research ID                                                                                             |
| organization_name       | GRID institution name                                                                                            |
| for_division            | discipline name                                                                                                  |
| researchers             | Number of researchers in given GRID and FOR in 2018                                                              |
| ResSameInst             | Share of researchers starting their career on the same institution (affiliated to the same institution in T<2)   |
| ResSameCountry          | Share of researchers starting their career on the same country (was affiliated to the same country in T<2)       |
| ResOtherInstSameCountry | Share of researchers starting in the same country, but on different institution (`ResSameCountry - ResSameInst`) |
| ResOtherCountry         | Share of researchers starting in other countries (`1 - (ResOtherInstSameCountry + ResSameInst)`)                 |
| country_code            | GRID institution country                                                                                         |
| latitude                | GRID institution latitude                                                                                        |
| longitude               | GRID institution longitude                                                                                       |

### 4. Filtering Leiden-ranking universities
The GRID universities were semi-automatically matched with Leiden Ranking universities. The final dataset only includes succesfully matched universities.

## Figures and tables for the paper
Notebook with generated figures for the full paper is available `./code/04_Figures_Tables.ipynb`