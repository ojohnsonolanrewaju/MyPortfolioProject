SELECT *
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT *
--FROM MyPortfolio.DBO.CovidVaccinations
--ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM MyPortfolio..CovidDeaths
ORDER BY 1,2;


-- Total cases Vs Total deaths
-- Chances of dying if you contract Covid in Germany

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM MyPortfolio..CovidDeaths
WHERE location LIKE '%germany%'
ORDER BY 1,2;

-- Total Cases vs Population
-- shows the percentage of population infected with COVID

SELECT location, date, population, total_cases,  (total_cases/population)*100 AS Percent_of_Infected_Population
FROM MyPortfolio..CovidDeaths
WHERE location LIKE '%germany%'
ORDER BY 1,2;

-- Countries with Highest Infection Rate Compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS Percent_of_Infected_Population
FROM MyPortfolio..CovidDeaths
GROUP BY location, population
ORDER BY Percent_of_Infected_Population DESC;

-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths AS INT)) AS total_deaths_count
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_deaths_count DESC;

-- Analysis by continents: Continent with Highest death counts

SELECT location, MAX(cast(total_deaths AS INT)) AS total_deaths_count
FROM MyPortfolio..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_deaths_count DESC;


SELECT continent, MAX(cast(total_deaths AS INT)) AS total_deaths_count
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths_count DESC;


-- Global numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM MyPortfolio..CovidDeaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2;

-- Total Population vs Vaccinations

SELECT *
FROM MyPortfolio..CovidVaccinations vac
JOIN MyPortfolio..CovidDeaths dea
ON vac.location = dea.location
AND
vac.date = dea.date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM MyPortfolio..CovidVaccinations vac
JOIN MyPortfolio..CovidDeaths dea
ON vac.location = dea.location
AND
vac.date = dea.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

With PopvsVac ( Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea. date) as RollingPeopleVaccinated
FROM MyPortfolio..CovidDeaths Dea
JOIN MyPortfolio..CovidVaccinations vac
ON dea.location = vac.location
AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *
FROM PopvsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea. date) as RollingPeopleVaccinated
FROM MyPortfolio..CovidDeaths dea
JOIN MyPortfolio..CovidVaccinations vac
ON dea.location = vac.location
AND
dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Create view for Data Visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea. date) as RollingPeopleVaccinated
FROM MyPortfolio..CovidDeaths dea
JOIN MyPortfolio..CovidVaccinations vac
ON dea.location = vac.location
AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL
