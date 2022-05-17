select * from CovidDeaths
order by 3,4

select * from CovidVaccinations
order by 3,4

-- select data that we are going to be using 
select location, date, total_Cases, new_Cases, total_deaths, population
from CovidDeaths
order by 1,2

-- looking at total cases vs total deaths in unitedstates.
--shows likelihood of dying of you contract covid in your country.
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from CovidDeaths
where location like '%state%'
order by 1,2

-- looking at total cases vs population & what % of population got covid.
select Location, date, total_cases, population, total_deaths, (total_cases/population)*100 as infectedPopulation_percentage
from CovidDeaths
where location like '%state%'
order by 1,2

--countries at highest infection rate compared to population
select Location, population, max(total_cases) highest_infection_Count, Max(total_cases/population)*100 as cases_percentage
from CovidDeaths
where location like '%states%'
order by 1,2

--showing countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as totaldeathcount
from portfolioProject..CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc

--death continent wise
select location, MAX(cast(total_deaths as int)) as totaldeathcount
from portfolioProject..CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc

--continent with highest death count
select continent, MAX(cast(total_deaths as int)) as totaldeathcount
from portfolioProject..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc

-- global numbers
select sum(new_cases) as total_cases, sum(cast(new_Deaths as int)), sum(cast(new_Deaths as int))/sum(new_cases)*100 as deathpercentage 
from portfolioProject..CovidDeaths
where continent is not null
order by 1,2

--join covid death and covid vaccination 
select * from 
PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--looking at total population vs vaccination.
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
From PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USE CTE 
With popVsVac (continent, location, date, population, new_vaccinations,  rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
From PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100 
from popVsVac 

-- TEMP table
DROP table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numric, 
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
From PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3
)
select *,(SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)/population)*100 
from popVsVac

--creating view 
create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
From PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
--order by 2,3