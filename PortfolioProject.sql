 select *
  from PortfolioProject.dbo.CovidDeaths$
  Where continent is not null
  order by 3,4

   select *
  from PortfolioProject.dbo.CovidVacinations$
  order by 3,4

  
  select location,date,total_cases,new_cases,total_deaths,population 
  from PortfolioProject..CovidDeaths$
  order by 1,2;

  --Looking at Total Cases vs Total Deaths

 
ALTER TABLE PortfolioProject..CovidDeaths$
alter column total_deaths float 

--Shows likelyhood of dying if you contract covid in the UK

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage 
  from PortfolioProject..CovidDeaths$
  where location like '%United kingdom%'
  order by 1,2

  --Total Cases vs Population 
  --Shows what percentage of population got covid

  select location,date,Population,total_cases, (total_cases/population)*100 AS PercentPopulationInfected 
  from PortfolioProject..CovidDeaths$
  where location like '%United kingdom%'
  order by 1,2


  --Looking at countries with highest infection rate compared to population

  Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%United Kingdom%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%United Kingdom%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%United Kingdom%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%United Kingdom%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select *
from PortfolioProject..CovidDeaths$ as Dea
join PortfolioProject..CovidVacinations$ as Vac
on Dea.location=Vac.location
and Dea.date=Vac.date

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by Dea.Location Order by Dea.location, Dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ Dea
Join PortfolioProject..CovidVacinations$ Vac
	On Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVacinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVacinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVacinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

