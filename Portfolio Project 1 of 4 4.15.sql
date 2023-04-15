

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types



Select *
from PortfolioTutorialv2..CovidDeaths$
Where continent is not null
order by 3,4


--Select *
--from PortfolioTutorialv2..CovidVaccinations$
--order by 3,4

-- Select Data we are going to use

Select location, date, total_cases, new_cases, 
total_deaths, population
from PortfolioTutorialv2..CovidDeaths$
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country
Select location, date, total_cases, total_deaths
, (total_deaths/total_cases)*100 as [Death Percetange]
from PortfolioTutorialv2..CovidDeaths$
Where location like '%states%'
order by 1,2

-- Total cases vs Population
-- Shows what percentage of population has gotten COVID
Select location, date, population, total_cases,
(total_cases/population)*100 as PercentPopulationInfected
from PortfolioTutorialv2..CovidDeaths$
Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfection,
MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioTutorialv2..CovidDeaths$
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc



-- Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as INT)) as TotalDeathCount
from PortfolioTutorialv2..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
Select location, MAX(cast(total_deaths as INT)) as TotalDeathCount
from PortfolioTutorialv2..CovidDeaths$
--Where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc




-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioTutorialv2..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select cd.continent, cd.location, cd.date, cd.population, 
cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) 
OVER (Partition by cd.location Order by cd.location,cd.date) as RollingPeopleVaccinated
from PortfolioTutorialv2..CovidDeaths$ cd
Join PortfolioTutorialv2..CovidVaccinations$ cv
on cd.location=cv.location
and cd.date=cv.date
Where cd.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
-- Number of columns in CTE needs to equal number of columns in query
With PopvsVac (Continent, location, date, population, New_Vaccinations,RollingPeopleVaccinated)
as
(Select cd.continent, cd.location, cd.date, cd.population, 
cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) 
OVER (Partition by cd.location Order by cd.location,cd.date) as RollingPeopleVaccinated
from PortfolioTutorialv2..CovidDeaths$ cd
Join PortfolioTutorialv2..CovidVaccinations$ cv
on cd.location=cv.location
and cd.date=cv.date
Where cd.continent is not null
--order by 2,3)
)Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255), 
location nvarchar(255),
date datetime, 
population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert Into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, 
cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) 
OVER (Partition by cd.location Order by cd.location,cd.date) as RollingPeopleVaccinated
from PortfolioTutorialv2..CovidDeaths$ cd
Join PortfolioTutorialv2..CovidVaccinations$ cv
on cd.location=cv.location
and cd.date=cv.date
Where cd.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, 
cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) 
OVER (Partition by cd.location Order by cd.location,cd.date) as RollingPeopleVaccinated
from PortfolioTutorialv2..CovidDeaths$ cd
Join PortfolioTutorialv2..CovidVaccinations$ cv
on cd.location=cv.location
and cd.date=cv.date
Where cd.continent is not null
--order by 2,3