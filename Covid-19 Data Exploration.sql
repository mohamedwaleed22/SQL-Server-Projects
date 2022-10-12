select * 
from PortfilioProject1..covid_deaths
where continent is not null
order by 3,4

--select * 
--from PortfilioProject1..covid_vaccination
--order by 3,4


--Shows the likelihood of dying if you contract covid in Egypt
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfilioProject1..covid_deaths
where location like '%egypt%'
order by 1,2


--Looking at Total cases vs Population------

select location, population, date, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as CovidPercentage
from PortfilioProject1..covid_deaths
--where location like '%egypt%'
Group by location, population, date
order by CovidPercentage desc

-- Looking at Countries with highest Infection Rate compared to Population-----

select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as CovidPercentage
from PortfilioProject1..covid_deaths
--where continent is not null
group by location, population
order by CovidPercentage desc

-- showing countries with Highest Death count per Population

select location, MAX(cast(total_deaths as int)) as TotalDEathCount
from PortfilioProject1..covid_deaths
where continent is not null
group by location
order by TotalDEathCount desc


-- showing continent with Highest Death count per Population-----

select location, sum(cast(new_deaths as int)) as TotalDEathCount
from PortfilioProject1..covid_deaths
where continent is null
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
group by location
order by TotalDEathCount desc

-- showing the continents with highest death count


select continent, MAX(cast(total_deaths as int)) as TotalDEathCount
from PortfilioProject1..covid_deaths
where continent is not null
group by continent
order by TotalDEathCount desc

-- global numbers----------

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfilioProject1..covid_deaths
where continent is not null
--group by date
order by 1,2

-- Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfilioProject1..covid_deaths dea
Join PortfilioProject1..covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3

-- Using CTE

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfilioProject1..covid_deaths dea
join PortfilioProject1..covid_vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
from PopVsVac

-- Temp Table

DROP Table if exists #PercentPoPulationVaccinated
Create Table #PercentPoPulationVaccinated
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPoPulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfilioProject1..covid_deaths dea
join PortfilioProject1..covid_vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPoPulationVaccinated


-- creating a view

Create view PercentPoPulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfilioProject1..covid_deaths dea
join PortfilioProject1..covid_vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null