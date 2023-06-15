SELECT * 
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4 

ALTER TABLE PortfolioProject..CovidDeaths$ 
ALTER COLUMN total_cases float;

ALTER TABLE PortfolioProject..CovidDeaths$ 
ALTER COLUMN total_deaths float;

-- SELECT THE DATA THAT WE ARE GOING TO USE
SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order By 1,2

-- Total Death VS Total Cases
-- Shows the likelihood of dying  if you contact covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
WHERE Location like '%India%'
Order By 1,2


-- Looking at the Total Cases VS Population
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS Percentage
From PortfolioProject..CovidDeaths$
--WHERE Location like '%India%'
Order By 1,2



--Looking at countries with highest infection rate compared to population

SELECT Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 AS Percentage
From PortfolioProject..CovidDeaths$
--WHERE Location like '%India%'
Group By Location,Population
Order By Percentage DESC

-- Showing Highest Death Count per Population

SELECT Location, MAX(total_deaths) as TotalDeath
From PortfolioProject..CovidDeaths$
where continent is not null
--WHERE Location like '%India%'
Group By Location
Order By TotalDeath DESC


-- Showing Highest Death Count per Population

SELECT continent, MAX(total_deaths) as TotalDeath
From PortfolioProject..CovidDeaths$
where continent is not null
--WHERE Location like '%India%'
Group By continent
Order By TotalDeath DESC



-- Global Numbers

SELECT SUM(new_cases) as Total_NewCases, SUM(cast(new_deaths as int)) as Total_NewDeaths ,
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS Death_Percentage
From PortfolioProject..CovidDeaths$
Where continent is not null
--Group by date
Order By 1,2

--Looking at Total Population Vs Vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON  dea.location = vac.location
	and dea.date = vac.date
--where dea.location LIKE '%India%'
where dea.continent is not null
order by 2,3

--Looking at  Total Population Vs Vaccinations percentage.

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON  dea.location = vac.location
	and dea.date = vac.date
--where dea.location LIKE '%India%'
where dea.continent is not null
order by 2,3


-- USING CTE

With PopvsVac(Continent, Location, Date, Population,NewVaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON  dea.location = vac.location
	and dea.date = vac.date
--where dea.location LIKE '%India%'
---order by 2,3
where dea.continent is not null
)
Select * , (RollingPeopleVaccinated/Population)
From PopvsVac





--TEMP  TABLE

DROP Table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	NewVaccinations numeric,
	RollingPeopleVaccinated numeric
)




Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON  dea.location = vac.location
	and dea.date = vac.date
--where dea.location LIKE '%India%'
---order by 2,3
--where dea.continent is not null




Select * , (RollingPeopleVaccinated/Population)
From #PercentPopulationVaccinated


--Creating View  to Store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON  dea.location = vac.location
	and dea.date = vac.date
--where dea.location LIKE '%India%'
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated


