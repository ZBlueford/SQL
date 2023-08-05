SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2;


--Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM CovidDeaths
ORDER BY 1,2;

--Looking at Total Cases vs Population per day in US

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS ContractionPercentage 
FROM CovidDeaths
WHERE location LIKE '%state%'
ORDER BY 1,2;

--Looking at countries w/Highest Contraction Rate compared to Population

SELECT Location, population
, MAX(total_cases) AS HighestInfectionCount
, MAX((total_cases/population))*100 AS ContractionPercentage 
FROM CovidDeaths
GROUP BY Location, population
ORDER BY ContractionPercentage DESC;

--Showing countries w/most deaths

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

--BREAKING THINGS DOWN BY CONTINENT
--Continents with the most deaths


SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


--Global numbers by date

SELECT date, SUM(new_cases) AS DailyNewCases, SUM(cast(new_deaths AS int)) AS DailyNewDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--Global Death Percentage

----per day

SELECT date, SUM(new_cases) AS DailyNewCases, SUM(cast(new_deaths AS int)) AS DailyNewDeaths
, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

----total

SELECT SUM(new_cases) AS GlobalNewCases, SUM(cast(new_deaths AS int)) AS GlobalNewDeaths
, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage 
FROM CovidDeaths
WHERE continent IS NOT NULL;


--Total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
WHERE dea.continent	IS NOT NULL
ORDER BY 1,2,3;


--Vaccination rolling count

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION By dea.location ORDER BY dea.location, dea.date) AS VaccinationRollingCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
WHERE dea.continent	IS NOT NULL
ORDER BY 2,3;

--Rolling percentage of population vaccinated using CTE


WITH PopvsVac (Continent, Location, Date, Population, New_Vaccintation, VaccinationRollingCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION By dea.location ORDER BY dea.location, dea.date) AS VaccinationRollingCount 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
WHERE dea.continent	IS NOT NULL
)

SELECT *, (VaccinationRollingCount/Population)*100
FROM PopvsVac;


--Rolling percentage of population vaccinated using Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccinationRollingCount numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION By dea.location ORDER BY dea.location, dea.date) AS VaccinationRollingCount 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
WHERE dea.continent	IS NOT NULL;

SELECT *, (VaccinationRollingCount/Population)*100
FROM #PercentPopulationVaccinated;

--Create a view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION By dea.location ORDER BY dea.location, dea.date) AS VaccinationRollingCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
WHERE dea.continent	IS NOT NULL;

SELECT * FROM PercentPopulationVaccinated;






















