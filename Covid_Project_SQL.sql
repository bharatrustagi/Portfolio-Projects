--Viewing the data tables

SELECT *
FROM Project_Covid..Covid_Deaths
ORDER BY 3,4;
SELECT *
FROM Project_Covid..Covid_Vaccinations
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Project_Covid..Covid_Deaths
ORDER BY 1;

--Total cases vs Total deaths
--Shows likelihood of dying if you contract covid in India

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
FROM Project_Covid..Covid_Deaths
WHERE location like '%india%'
ORDER BY 1,2;


--Total Cases Vs. Population

SELECT location, date, total_cases, population, (total_cases/population)*100 CasePercentage
FROM Project_Covid..Covid_Deaths
WHERE location like '%india%'
ORDER BY 1,2;


--Countries with highest infection rate compared to Population

SELECT location, MAX(total_cases) HighestInfectionCount, population, MAX((total_cases/population))*100 CasePercentage
FROM Project_Covid..Covid_Deaths
--WHERE location like '%india%'
GROUP BY location, population
ORDER BY CasePercentage desc;


--Countries with highest death count

SELECT location, MAX(cast(total_deaths as bigint)) TotalDeathCount
FROM Project_Covid..Covid_Deaths
--WHERE location like '%india%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;


--Continents with highest death count

SELECT continent, MAX(cast(total_deaths as bigint)) TotalDeathCount
FROM Project_Covid..Covid_Deaths
--WHERE location like '%india%'
WHERE continent is NOT null
GROUP BY continent
ORDER BY TotalDeathCount desc;


--Global Numbers

--Date-wise

SELECT date, SUM(new_cases) TotalCases, SUM(CAST(new_deaths as bigint)) TotalDeaths, SUM(CAST(new_deaths as bigint))/SUM(new_cases)*100 DeathPercentage
FROM Project_Covid..Covid_Deaths
--WHERE location like '%india%'
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2;

--Total

SELECT SUM(new_cases) TotalCases, SUM(CAST(new_deaths as bigint)) TotalDeaths, SUM(CAST(new_deaths as bigint))/SUM(new_cases)*100 DeathPercentage
FROM Project_Covid..Covid_Deaths
--WHERE location like '%india%'
WHERE continent is NOT NULL
ORDER BY 1,2;


--Total population vs. Vaccinations (per day)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Project_Covid..Covid_Deaths dea
JOIN Project_Covid..Covid_Vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 1,2,3;


--Rolling Total of Vaccinations Done

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingTotalVac
FROM Project_Covid..Covid_Deaths dea
JOIN Project_Covid..Covid_Vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 1,2,3;


--Total population vs. Rolling Vaccinations count (Using CTE)

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingTotalVac)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingTotalVac
FROM Project_Covid..Covid_Deaths dea
JOIN Project_Covid..Covid_Vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 1,2,3;
)
SELECT *, (RollingTotalVac/population)*100 RolVacPrcnt
FROM PopVsVac



--Total population vs. Total Vaccinations (location-wise) (Temp table)


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingTotalVac numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingTotalVac
FROM Project_Covid..Covid_Deaths dea
JOIN Project_Covid..Covid_Vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 1,2,3

SELECT *, (RollingTotalVac/population)*100 RolVacPrcnt
FROM #PercentPopulationVaccinated;



--Creating Views to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingTotalVac
FROM Project_Covid..Covid_Deaths dea
JOIN Project_Covid..Covid_Vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 1,2,3;

SELECT *
FROM PercentPopulationVaccinated;
