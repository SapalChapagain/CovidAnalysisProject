SELECT * FROM dbo.CovidDeaths
WHERE location LIKE '%states%' OR location LIKE '%thailand%' 
ORDER BY 3,4

SELECT * FROM dbo.CovidVaccinations
WHERE location LIKE '%states%' OR location LIKE '%thailand%' 
ORDER BY 3,4

--This is what we will use in our analysis

SELECT location, date, total_cases, new_cases, total_deaths
FROM dbo.CovidDeaths
WHERE location LIKE '%states%' OR location LIKE '%thailand%' 
ORDER BY location, date

--Total Cases as compared to Total Deaths - Shows how likely it is that you will die by country
--Interesting insight: as time has progressed, death percentage is decreases even as cases increase 
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location LIKE '%states%' OR location LIKE '%thailand%' 
ORDER BY location, date 

--Total Cases as compared to Population

SELECT location, date, total_cases, population, ROUND((total_cases/population)*100,2) AS CovidContractionPercentage
FROM dbo.CovidDeaths
--WHERE location LIKE '%states%' 
WHERE continent is not NULL
ORDER BY location, date 

--Country with the highest inflection rate compared to population
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population)*100) AS CovidContractionPercentage
FROM dbo.CovidDeaths
WHERE location LIKE '%states%' OR location LIKE '%thailand%' 
GROUP BY Location, Population 
ORDER BY CovidContractionPercentage DESC

--Showing Countries With Highest Death Count compared to population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE location LIKE '%states%' OR location LIKE '%thailand%' 
GROUP BY Location 
ORDER BY TotalDeathCount DESC

--Comparision by CONTINENT

--Highest death count by continent

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE location LIKE '%states%' OR location LIKE '%thailand%' 
GROUP BY continent 
ORDER BY TotalDeathCount DESC


--Global Numbers

SELECT  date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as GlobalDeathPercentage
FROM dbo.CovidDeaths
WHERE location LIKE '%states%' OR location LIKE '%thailand%' 
GROUP BY date
ORDER BY 1,2

--Percentage of deaths

SELECT  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as GlobalDeathPercentage
FROM dbo.CovidDeaths
WHERE location LIKE '%states%' OR location LIKE '%thailand%' 
ORDER BY 1,2

--Total Population VS Vaccination

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations, SUM(CONVERT(bigint, vax.new_vaccinations))
OVER (Partition by deaths.location ORDER BY deaths.location, deaths.Date) as VaccineRollCount
FROM dbo.CovidDeaths deaths
INNER JOIN dbo.CovidVaccinations vax
	ON deaths.location = vax.location
	and deaths.date = vax.date
WHERE deaths.location LIKE '%states%' OR deaths.location LIKE '%thailand%' 
	ORDER BY 2,3

--TEMP TABLE
DROP Table if exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
VaccineRollCount numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations, SUM(CONVERT(bigint, vax.new_vaccinations))
OVER (Partition by deaths.location ORDER BY deaths.location, deaths.Date) as VaccineRollCount
FROM dbo.CovidDeaths deaths
INNER JOIN dbo.CovidVaccinations vax
	ON deaths.location = vax.location
	and deaths.date = vax.date
WHERE deaths.location LIKE '%states%' OR deaths.location LIKE '%thailand%'

SELECT * FROM dbo.CovidDeaths

SELECT *, (VaccineRollCount/Population) * 100
FROM #PercentagePopulationVaccinated

--Creating View

CREATE VIEW PercentagePopulationVaccinated as
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations, SUM(CONVERT(bigint, vax.new_vaccinations))
OVER (Partition by deaths.location ORDER BY deaths.location, deaths.Date) as VaccineRollCount
FROM dbo.CovidDeaths deaths
INNER JOIN dbo.CovidVaccinations vax
	ON deaths.location = vax.location
	and deaths.date = vax.date
WHERE deaths.location LIKE '%states%' OR deaths.location LIKE '%thailand%' 

SELECT * 
FROM PercentagePopulationVaccinated