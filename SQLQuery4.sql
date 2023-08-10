-- Taking a look at the data

SELECT *
FROM PortfolioP1..CovidDeaths

-- Selecting the data that is gonna be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioP1..CovidDeaths

-- Changing data types so it allows to perform basic calculations

ALTER TABLE PortfolioP1..CovidDeaths
ALTER COLUMN total_cases FLOAT;

ALTER TABLE PortfolioP1..CovidDeaths
ALTER COLUMN new_cases FLOAT;

ALTER TABLE PortfolioP1..CovidDeaths
ALTER COLUMN total_deaths INT;

ALTER TABLE PortfolioP1..CovidDeaths
ALTER COLUMN population FLOAT;

ALTER TABLE PortfolioP1..CovidDeaths
ALTER COLUMN new_deaths FLOAT;


-- Total Cases vs Total Deaths
-- Shows the percentage of death rate from Covid in Portugal

SELECT location, date, total_cases, total_deaths,
       CASE
           WHEN total_cases <> 0 THEN (total_deaths * 1.0 / total_cases) * 100
           ELSE NULL
       END AS death_rate_percentage
FROM PortfolioP1..CovidDeaths
WHERE location = 'Portugal'
ORDER BY 1, 2

--Looking at the Total Cases vs Population in Portugal
-- Shows what percentage of the Portuguese population got infected with COVID since the beggining of the pandemy

SELECT location, date, population, total_cases,
       CASE
           WHEN total_cases <> 0 THEN (total_cases * 1.0 / population) * 100
           ELSE NULL
       END AS Infected_percentage
FROM PortfolioP1..CovidDeaths
WHERE location = 'Portugal'
ORDER BY 1, 2

-- Finding which countrys have the highest infection rate compared to the population

SELECT location,
       population AS total_population,
       MAX(total_cases) AS Highest_Infection_Count,
       CASE
           WHEN MAX(total_cases) <> 0 THEN (MAX(total_cases) * 1.0 / population) * 100
           ELSE NULL
       END AS Infected_percentage
FROM PortfolioP1..CovidDeaths
GROUP BY location, population
ORDER BY Infected_percentage DESC

-- Finding which countrys have the highest death count from COVID

SELECT location, MAX(total_deaths) AS total_death_count
FROM PortfolioP1..CovidDeaths
WHERE continent <> ' '
GROUP BY location
ORDER BY total_death_count DESC


-- Let's see data about the continents
-- Let's find which continents have the highest death count from COVID
-- The data source has some errors, so i adapted my query until I got the answers that we need!

SELECT location, MAX(total_deaths) AS total_death_count
FROM PortfolioP1..CovidDeaths
WHERE continent = ' ' 
  AND location NOT IN ('lower middle income', 'low income', 'upper middle income', 'high income', 'World', 'European Union')
GROUP BY location
ORDER BY total_death_count DESC;


-- GLOBAL NUMBERS
-- In each day, new covid cases across the world.


SELECT date, SUM(new_cases) 
FROM PortfolioP1..CovidDeaths
WHERE continent = ' '
  AND location NOT IN ('lower middle income', 'low income', 'upper middle income', 'high income', 'World', 'European Union')
GROUP BY date
ORDER BY 1,2


--Number of cases, deaths and the death percentage of each day globally

SELECT date,
       SUM(new_cases) AS Total_cases,
       SUM(new_deaths) AS Total_deaths,
       CASE
           WHEN SUM(new_cases) <> 0 THEN (SUM(new_deaths) * 1.0 / SUM(new_cases)) * 100
           ELSE NULL
       END AS Death_Percentage
FROM PortfolioP1..CovidDeaths
WHERE continent = ' '
  AND location NOT IN ('lower middle income', 'low income', 'upper middle income', 'high income', 'World', 'European Union')
GROUP BY date
ORDER BY 1,2

--Total numbers of covid infections, death count and death percentage globally

SELECT 
       SUM(new_cases) AS Total_cases,
       SUM(new_deaths) AS Total_deaths,
       CASE
           WHEN SUM(new_cases) <> 0 THEN (SUM(new_deaths) * 1.0 / SUM(new_cases)) * 100
           ELSE NULL
       END AS Death_Percentage
FROM PortfolioP1..CovidDeaths
WHERE continent = ' '
  AND location NOT IN ('lower middle income', 'low income', 'upper middle income', 'high income', 'World', 'European Union')
ORDER BY 1,2


-- Looking at total population vs new vaccinations per day with a rolling count of the number of people vaccinated for each country

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed, 
SUM(CAST(vac.new_vaccinations_smoothed as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_Count
FROM PortfolioP1..CovidDeaths AS dea
JOIN PortfolioP1..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> ' '
ORDER BY 2,3

-- Creating a CTE to perform further calculations
-- Finding the total population vs new vaccinations per country

with PopvsVac (continent, location, date, population, new_vaccinations_smoothed, rolling_count)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed, 
SUM(CAST(vac.new_vaccinations_smoothed as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_Count
FROM PortfolioP1..CovidDeaths AS dea
JOIN PortfolioP1..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> ' '
)
SELECT *
FROM PopvsVac


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed, 
SUM(CAST(vac.new_vaccinations_smoothed as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_Count
FROM PortfolioP1..CovidDeaths AS dea
JOIN PortfolioP1..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> ' '
--ORDER BY 2,3

DROP VIEW IF EXISTS PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed, 
       SUM(CAST(vac.new_vaccinations_smoothed as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_Count
FROM PortfolioP1..CovidDeaths AS dea
JOIN PortfolioP1..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent <> ' ';



