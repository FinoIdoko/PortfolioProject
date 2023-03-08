

select*
from portfolioproject..CovidDeaths
where continent is not null
order by 3,4


--select*
--from portfolioproject..CovidVaccinations
--order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths population
from portfolioproject..CovidDeaths
where continent is not null
order by 1,2

--looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from portfolioproject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


--looking at total number of cases vs population
-- shows what percentage of people got covid

select Location, Date, Population total_cases, (total_cases/population)*100 as percentpopulationinfected
from portfolioproject..CovidDeaths
--where location like '%states%'
order by 1,2

--Looking at the Countries with Highest Infection Rate Compared to Population


select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as percentpopulationinfected
from portfolioproject..CovidDeaths
--where location like '%states%'
Group by Location, Population
order by percentpopulationinfected desc

--Showing Countries with Highest Death Count per Population

select Location, Max(Cast(Total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by  continent
order by TotalDeathCount desc

--BREAKING THINGS DOWN BY CONTINENT

--Showing continent with highest death count per population

select continent, Max(Cast(Total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc



--global numbers


select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 as deathpercentage
from portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group By date
order by 1,2

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


--USE CTE

With PopvsVac (Continent, Location, date, Population, New_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac




--TEMP TABLE
DROP table if exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)



INSERT INTO  #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from  #PercentagePopulationVaccinated

--Creating views for visualisations

create view  PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

select *
from PercentagePopulationVaccinated