select *
from PortfolioProject..CovidDeaths$
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

-- Select Data that we are going to be using 
select location, date, total_cases, new_cases, total_deaths,population
from PortfolioProject..CovidDeaths$
order by 1,2

--looking at the total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at the total cases vs the population
-- shows what % of population got covid 
select location, date, total_cases,population,(total_cases/population)*100 as Percentageofpopulation
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--looking at countires with highest infection rate compared to population
select location,population,MAX(total_cases) as Highestinfectioncount, MAX((total_cases/population))*100 as Percentpopulationinfected
from PortfolioProject..CovidDeaths$
group by location,population
order by Percentpopulationinfected desc

-- Showing the countires with highest death count per population
select location,MAX(cast(total_deaths as int)) as TotalDeathcount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathcount desc

-- Lets Breakdown by Continent 
select location,MAX(cast(total_deaths as int)) as TotalDeathcount
from PortfolioProject..CovidDeaths$
where continent is null
group by location
order by TotalDeathcount desc

--GLOBAL NUMBERS
select date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null 
group by date
order by 1,2



Select *
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date

-- Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.Date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
With PopvsVac( Continent, location, date, population,new_vaccinations,Rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.Date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
)
select *, (Rollingpeoplevaccinated/population)*100
from PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.Date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null

select *, (Rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visulaizations

Create View PercentpopulatioVaccinated as 
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.Date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
