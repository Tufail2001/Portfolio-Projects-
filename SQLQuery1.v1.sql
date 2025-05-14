
SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT NULL
ORDER by 1,2

--Looking at Total Cases Vs Total Death
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%States%'
ORDER BY DeathPercentage

--Looking at Total Cases VS Population
--Shows what percentage of population got covid

SELECT location, date, total_cases, total_deaths, population, (total_cases/population)*100 AS CovidPatientPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%States%'
ORDER BY 1, 

-- Looking at the country with Highest No of Covid Patients

SELECT location, population, MAX(total_cases) AS HighestInfectedCount, MAX(total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

--Showing Countries With Highest Death Count per  Population 

SELECT location,  MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing the continent with highest death count per population

SELECT continent,  MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths$
WHERE continent is  NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL STATS

SELECT date, SUM(cast(new_cases as int)) AS total_cases, SUM(cast(total_deaths as int)) AS total_deaths, 
(SUM(cast(total_deaths as int))/SUM(cast(new_cases as int)))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2

--Looking at Total Population Vs Vaccinations

--USE CTE 

With PopvsVac(Continent, Location, Date, Population, New_vaccinations,RollingPeopleVaccinated )
as  

(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, dea.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL

)

SELECT *, (RollingPeopleVaccinated/Population)*100 As RollingPeopleVacPercentage
FROM PopvsVac

  



--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, dea.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated  


--Create View to store data for later use

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, dea.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL

SELECT * 
FROM PercentPopulationVaccinated
