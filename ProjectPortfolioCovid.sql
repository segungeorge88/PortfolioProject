-- Standarize Date Format
--CovidDeaths
SELECT * 
FROM PortfolioProject.dbo.CovidDeaths

ALTER TABLE PortfolioProject.dbo.coviddeaths
Add DateConverted Date;

UPDATE PortfolioProject.dbo.coviddeaths 
SET DateConverted =  CONVERT (Date,date)

--CovidVaccinations
SELECT * 
FROM PortfolioProject.dbo.CovidVaccinations

ALTER TABLE PortfolioProject.dbo.CovidVaccinations
Add DateConverted Date;

UPDATE PortfolioProject.dbo.CovidVaccinations
SET DateConverted =  CONVERT (Date,date)

----------------------------------------------------------------------------------------------------------------------------------------------------------------

--Viewing the dataset
SELECT location, Dateconverted, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
Order By 1, 2
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

--Infection rate in United States
SELECT location, Dateconverted, Population, total_cases, total_deaths, (total_cases/Population) * 100 as InfectionRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE LOCATION like '%State%'
Order By 1, 2
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Death rate in United States
SELECT location,Dateconverted, Population, total_cases, total_deaths, (total_deaths/Population) * 100 as DeathRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE LOCATION like '%State%'
Order By 1, 2
------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Highest infection rate compared to population
SELECT location, Population, MAX (Total_cases) as Highest_Infection_Count, MAX((total_cases/Population)) * 100 as InfectionRate
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY Location, population
Order By 4 DESC
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Highest death count per population
SELECT location, Population, MAX (cast(total_deaths as int)) as Highest_Death_Count, MAX((total_deaths/Population)) * 100 as DeathRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location, population
Order By 3 DESC
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Continent wth highest death count
SELECT continent, MAX (cast(total_deaths as int)) as Highest_Death_Count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
Order By 2 DESC
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Grouping by Location
SELECT location, MAX (cast(total_deaths as int)) as Highest_Death_Count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is null
GROUP BY Location
Order By 2 DESC
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Global Numbers
SELECT  DateConverted, Sum(new_cases) as NewCases, Sum(cast(new_deaths as int)) as NewDeaths, Sum(cast(new_deaths as int)) / Sum(new_cases) * 100 as DeathRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
Group by DateConverted
Order By 1, 2
-- p.s: cast or convert can be used to change datatype
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Number of people vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location order by dea.location, dea.dateConverted) as RollingPeopleVaccination
From PortfolioProject.dbo.CovidVaccinations as vac
Join PortfolioProject.dbo.coviddeaths as dea
	ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
Order by 2,3
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Percentage of people vaccinated
--Using CTE
With PopulationVsVaccination (continent,Location, dateConverted, population, NewVaccinations, RollingPeopleVaccinnated)
as(
Select dea.continent, dea.location, dea.dateConverted, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location order by dea.location, dea.dateConverted) as RolligPeopleVaccination
From PortfolioProject.dbo.CovidVaccinations as vac
Join PortfolioProject.dbo.coviddeaths as dea
	ON dea.location = vac.location and dea.dateConverted = vac.dateConverted
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinnated/ population) * 100 as VaccinationRate
From PopulationVsVaccination

--Percentage of people vaccinated(using another methods)
--Using TempTable
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
 (continent nvarchar(255),
 Location nvarchar(255),
 date datetime,
 population numeric, 
 NewVaccinations numeric,
 RollingPeopleVaccinnated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location order by dea.location, dea.date) as RolligPeopleVaccination
From PortfolioProject.dbo.CovidVaccinations as vac
Join PortfolioProject.dbo.coviddeaths as dea
	ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
Order by 2,3
Select *, (RollingPeopleVaccinnated/ population) * 100 as VaccinationRate
From #PercentPopulationVaccinated
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Creating View to Number of people vaccinated
CREATE VIEW NumberPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location order by dea.location, dea.dateConverted) as RollingPeopleVaccination
From PortfolioProject.dbo.CovidVaccinations as vac
Join PortfolioProject.dbo.coviddeaths as dea
	ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null

Select* 
From NumberPopulationVaccinated