select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio_p1_Covid..CovidDeaths$
order by 1,2

--- Total Cases vs Total Deaths per country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from Portfolio_p1_Covid..CovidDeaths$
where continent is not null
order by 1,2

--- Total Cases vs Total Deaths in Greece
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from Portfolio_p1_Covid..CovidDeaths$
where location like '%Greece%'
order by 1,2

--- Percentage of Greek population that got covid
select Location, date, total_cases, population, (total_deaths/total_cases)*100 as Infection_Percentage_GR
from Portfolio_p1_Covid..CovidDeaths$
where location like '%Greece%'
order by 1,2

--- Which countries have the highest infection rates compared to the population
select Location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Population_Infection_Rate
from Portfolio_p1_Covid..CovidDeaths$
where continent is not null
group by Location, population
order by Population_Infection_Rate desc

--- Countries with highest death rate per population
select Location,MAX(cast(total_deaths as int)) as Total_Death_Count
from Portfolio_p1_Covid..CovidDeaths$
where continent is not null
group by Location
order by Total_Death_Count desc

--- Continents with highest death rate per population
select location, MAX(cast(total_deaths as int)) as Total_Death_Count_Continent
from Portfolio_p1_Covid..CovidDeaths$
where continent is null
group by location
order by Total_Death_Count_Continent desc

---  Death percentage across the world
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as death_percentage
from Portfolio_p1_Covid..CovidDeaths$
where continent is not null
order by 1,2

--- Check how vaccinations are rolling in each country 
With PopVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
From Portfolio_p1_Covid..CovidDeaths$ dea
Join Portfolio_p1_Covid..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (PeopleVaccinated/Population)*100
From PopVac

-- Percentage of population in each country that has been vaccinated against Covid at least once

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_p1_Covid..CovidDeaths$ dea
Join Portfolio_p1_Covid..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3