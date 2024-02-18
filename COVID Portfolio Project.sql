select*
from SQL_Portfolio..CovidDeaths
where continent is not null
order by 3,4

--select*
--from SQL_Portfolio..CovidVaccinations
--order by 3,4


select Location, date, total_cases, new_cases, total_deaths, population
from SQL_Portfolio..CovidDeaths
where continent is not null
order by 1,2

-- looking at total cases vs total deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from SQL_Portfolio..CovidDeaths
Where location like 'Pakistan'
and continent is not null
order by 1,2

-- looking at Total cases vs Population
-- Shows what percentage os population got Covid
select Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from SQL_Portfolio..CovidDeaths
where continent is not null
--and location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from SQL_Portfolio..CovidDeaths
where continent is not null
--and location like '%states%'
group by Location, population
order by PercentPopulationInfected desc


-- Showing the Countries with Hightest Deaths Count Per Population

select Location, MAX(cast(total_deaths as int)) AS  TotalDeathCount
from SQL_Portfolio..CovidDeaths
--Where location like '%states%'
where continent is not null
group by Location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) AS  TotalDeathCount
from SQL_Portfolio..CovidDeaths
--Where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers

select  SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int))as Total_Deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from SQL_Portfolio..CovidDeaths
--Where location like 'Pakistan'
where continent is not null
 --GROUP BY date
order by 1,2


--JOIN THE TABLES "DEATHS AND VACCINATIONS"

--looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated

from SQL_Portfolio..CovidDeaths as dea
join SQL_Portfolio..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations,RollingpeopleVaccinated) 
as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated

from SQL_Portfolio..CovidDeaths as dea
join SQL_Portfolio..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingpeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE
Drop table if exists #PercentPopulationVAccinated
CREATE TABLE  #PercentPopulationVAccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingpeopleVaccinated numeric
)

Insert into #PercentPopulationVAccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated

from SQL_Portfolio..CovidDeaths as dea
join SQL_Portfolio..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingpeopleVaccinated/Population)*100
from #PercentPopulationVAccinated


-- Creating VIEW to store data for later visualization

create view PercentPopulationVAccinated as
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated

from SQL_Portfolio..CovidDeaths as dea
join SQL_Portfolio..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * 
from PercentPopulationVAccinated