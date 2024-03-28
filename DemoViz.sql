Select * 
from DemoDB..[Covid deaths]
Where continent is not Null
Order by 3,4

Select * 
from DemoDB..[Covid Vaccinations]
Order by 3,4

--Now we will be using the Data From the tables

Select location, date, total_cases, new_cases, total_deaths, population 
from DemoDB..[Covid deaths]
Order by 1,2

-- Looking at the cases vs death ratio wrt few countries (INDIA)

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from DemoDB..[Covid deaths]
Where location like '%india%'
and continent is not Null
order by 1,2

-- Looking at the cases vs death ratio wrt few countries (UNITED STATES)
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from DemoDB..[Covid deaths]
Where location like '%states%'
and continent is not Null
order by 1,2

--Looking at total cases vs Population
--Shows what percentage of the total population was effected by Covid (India)
Select location, date, total_cases,Population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Total_Effected_Population
from DemoDB..[Covid deaths]
Where location like '%india%'
and continent is not Null
order by 1,2

--We will do the above filtering for United States as well
--Looking at total cases vs Population (United States)
Select location, date, total_cases,Population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Total_Effected_Population
from DemoDB..[Covid deaths]
Where location like '%states%'
and continent is not Null
order by 1,2

--The below query will give us the highest Infection rate Countrywise wrt their Population
Select location, max(total_cases) as Total_no_ofcases,Population, 
max((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS TotalInfected_Population
from DemoDB..[Covid deaths]
--Where location like '%india%'
Where continent is not Null
Group by location,Population
order by Total_no_ofcases desc

--The above query will get us the death's rate location wise

Select continent, max(cast(total_deaths as int)) as Totaldeathcount
from DemoDB..[Covid deaths]
--Where location like '%india%'
Where continent is not Null
Group by continent
order by Totaldeathcount desc

SELECT SUM(new_cases) AS totalno_ofcases, 
       SUM(new_deaths) as New_Deaths,
       CASE WHEN SUM(new_cases) = 0 THEN 0 
            ELSE SUM(new_deaths) / SUM(new_cases) * 100 
       END as DeathRatio 
FROM DemoDB..[Covid deaths]
WHERE continent is not null
--GROUP BY date,continent
ORDER BY 1,2

--Let's look at the cousin table for a sec (Vaccination)

select *
from DemoDB..[Covid Vaccinations]

Select *
from DemoDB..[Covid deaths] dea
Join DemoDB..[Covid Vaccinations] vacci
on dea.location = vacci.location
and dea.date = vacci.date

-- We look at the total number of people all around the world who got vaccinated
select dea.continent, dea.location, dea.date, dea.population, vacci.new_vaccinations
,sum(convert(bigint,vacci.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from DemoDB..[Covid deaths] dea
Join DemoDB..[Covid Vaccinations] vacci
on dea.location = vacci.location
and dea.date = vacci.date
where dea.continent is not null
order by 2,3


--Using CTE

with Total_VacciPoP(continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vacci.new_vaccinations
,sum(convert(bigint,vacci.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from DemoDB..[Covid deaths] dea
Join DemoDB..[Covid Vaccinations] vacci
on dea.location = vacci.location
and dea.date = vacci.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100
from Total_VacciPoP

--The second way of doing this might be to create a temp Table
	Drop table if exists #TotalVaccinatedPopulation
	Create table #TotalVaccinatedPopulation
	(
	continent nvarchar(255),
	location  nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

	insert into #TotalVaccinatedPopulation
	select dea.continent, dea.location, dea.date, dea.population, vacci.new_vaccinations
	,sum(convert(bigint,vacci.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
	from DemoDB..[Covid deaths] dea
	Join DemoDB..[Covid Vaccinations] vacci
	on dea.location = vacci.location
	and dea.date = vacci.date
	--where dea.continent is not null
	--order by 2,3

	Select * , (RollingPeopleVaccinated/population)*100
	from #TotalVaccinatedPopulation



create view 
deathratelocationwiseIndia 
as
Select continent, max(cast(total_deaths as int)) as Totaldeathcount
from DemoDB..[Covid deaths]
--Where location like '%india%'
Where continent is not Null
Group by continent
--order by Totaldeathcount desc

Select * from deathratelocationwiseIndia

create view TotalVaccinatedPopulation
as select dea.continent, dea.location, dea.date, dea.population, vacci.new_vaccinations
	,sum(convert(bigint,vacci.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
	from DemoDB..[Covid deaths] dea
	Join DemoDB..[Covid Vaccinations] vacci
	on dea.location = vacci.location
	and dea.date = vacci.date
	--where dea.continent is not null
	--order by 2,3

select * from TotalVaccinatedPopulation



create view TotaldeathsinIndiaDatewise
as select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from DemoDB..[Covid deaths]
Where location like '%india%'
and continent is not Null
--order by 1,2

select * from TotaldeathsinIndiaDatewise


create view MostInfectedCountries
as Select location, max(total_cases) as Total_no_ofcases,Population, 
max((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS TotalInfected_Population
from DemoDB..[Covid deaths]
--Where location like '%india%'
Where continent is not Null
Group by location,Population
--order by Total_no_ofcases desc


select * from MostInfectedCountries