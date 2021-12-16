-- Exploring the COVID-19 data from "Our World In Data" / 
-- �������� ������ � COVID-19 �� "Our World In Data"  

SELECT *
FROM Covid_Data_Exploration..Covid_Deaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject_1..Covid_Vaccination
--ORDER BY 3,4

-- Select data that we are going to be using / 
-- �������� ������, ������� ����� ������������

SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM Covid_Data_Exploration..Covid_Deaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths / 
-- ���������� ����� ���������� ������� � ����������� �������

SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	new_deaths,
	total_deaths, 
	ROUND((total_deaths/total_cases)*100, 2) AS DeathPersentage
FROM Covid_Data_Exploration..Covid_Deaths
WHERE location like '%Russia%'
ORDER BY 1,2

-- Looking at Total Cases vs Population / 
-- ���������� ���������� ������� � ���������� ���������� ������

SELECT 
	location, 
	date,
	population, 
	total_cases, 
	ROUND((total_cases/population)*100, 2) AS PersentPopulation_Infected
FROM Covid_Data_Exploration..Covid_Deaths
WHERE location like '%Russia%'
ORDER BY 1,2


-- Looking at countries with highest infection rates compared to Population / 
-- ������� � ����� �������� ������ ���������� ������������ ���������.

SELECT 
	location, 
	population, 
	MAX(total_cases) as infection_count, 
	MAX(ROUND((total_cases/population)*100, 2)) AS PersentPopulation_Infected
FROM Covid_Data_Exploration..Covid_Deaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PersentPopulation_Infected DESC


-- Showing Countries with highest Death Count per Popularion /
-- ������� �� ������ � ������� ����������� ������������ ���������

SELECT 
	location, 
	population, 
	MAX(cast(total_deaths as int)) as Death_Count, 
	MAX(ROUND((total_deaths/population)*100, 2)) AS PersentPopulation_Died
FROM Covid_Data_Exploration..Covid_Deaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PersentPopulation_Died DESC

-- LET'S BREAK THINGS DOWH BY CONTINENT /
-- �������� ������ �� �����������

-- Showing continents with the highest death count per population
-- ���������� ���������� � ���������� ����������� ������� ������������ ���������

SELECT 
	continent,  
	MAX(cast(total_deaths as int)) as Death_Count, 
	MAX(ROUND((total_deaths/population)*100, 2)) AS PersentPopulation_Died
FROM Covid_Data_Exploration..Covid_Deaths
WHERE continent is not null
GROUP BY continent
ORDER BY PersentPopulation_Died DESC


--  Commented out query represents continents data correctly,
-- however it does not allow for drill down since it is the wrong collumn


--SELECT 
--	location,  
--	MAX(cast(total_deaths as int)) as Death_Count, 
--	MAX(ROUND((total_deaths/population)*100, 2)) AS PersentPopulation_Died
--FROM Covid_Data_Exploration..Covid_Deaths
----WHERE location like '%Russia%'
--WHERE continent is null
--GROUP BY location
--ORDER BY PersentPopulation_Died DESC


-- GLOBAL NUMBERS
-- ������� ������

-- Daily Infections and Deaths Globaly
-- ���������� ��������� � ������ �� ����

SELECT  
	date, 
	SUM(new_cases) AS total_infections,
	SUM(cast(new_deaths as int)) AS total_deaths,
	ROUND((SUM(cast(new_deaths as int))/SUM(new_cases))*100, 2) AS death_rate
FROM Covid_Data_Exploration..Covid_Deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1

-- Total Infections and Deaths Globaly
-- ����� ���������� ��������� � ������� �� ����

SELECT 
	SUM(new_cases) AS total_infections,
	SUM(cast(new_deaths as int)) AS total_deaths,
	ROUND((SUM(cast(new_deaths as int))/SUM(new_cases))*100, 2) AS death_rate
	--total_deaths, 
	--ROUND((total_deaths/total_cases)*100, 2) AS DeathPersentage
FROM Covid_Data_Exploration..Covid_Deaths
WHERE continent is not null


-- Joinning Deaths and Vaccination tables
-- Looking at Population vs Vaccination
-- ��������� ������� "������" � "����������"
-- ���������� ��������� ������ � ����������

SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS rolling_vaccinations
FROM Covid_Data_Exploration..Covid_Deaths AS dea
JOIN Covid_Data_Exploration..Covid_Vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE
-- ���������� CTE

WITH PopvsVac 
	(continent, location, date, population,
	new_vaccinations, rolling_vaccinations)
AS
(
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS rolling_vaccinations
FROM Covid_Data_Exploration..Covid_Deaths AS dea
JOIN Covid_Data_Exploration..Covid_Vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, 
	ROUND((rolling_vaccinations/Population)*100,2) AS percent_vaccinated
FROM PopvsVac
WHERE location like '%Russia%'


-- Showing how many people got at least one dose of vaccine 
-- and what is their % of population /
-- ���������� ������� ����� �������� ���� �� ��� ���� �������
-- � ����� % ��������� ��� ����������

SELECT 
	dea.continent,
	dea.location,
	dea.population,
	MAX(CAST(vac.people_vaccinated AS int)) AS at_least_1_dose_total,
	ROUND((MAX(CAST(vac.people_vaccinated AS int))/dea.population)*100,2) 
	AS percent_at_least_1_dose
FROM Covid_Data_Exploration..Covid_Deaths AS dea
JOIN Covid_Data_Exploration..Covid_Vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
	--AND dea.location like '%Russia%'
GROUP BY dea.continent, dea.location, dea.population
ORDER BY percent_at_least_1_dose DESC


-- Same Vaccination data with search for specific country
-- ����� �� ���������� �� ���������� ������

SELECT 
	dea.continent,
	dea.location,
	dea.population,
	MAX(CAST(vac.people_vaccinated AS int)) AS at_least_1_dose_total,
	ROUND((MAX(CAST(vac.people_vaccinated AS int))/dea.population)*100,2) 
	AS percent_at_least_1_dose
FROM Covid_Data_Exploration..Covid_Deaths AS dea
JOIN Covid_Data_Exploration..Covid_Vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
	AND dea.location like '%Russia%'
GROUP BY dea.continent, dea.location, dea.population


-- TEMP TABLE
-- ��������� �������

DROP TABLE if exists #People_with_at_least_1_dose

CREATE TABLE #People_with_at_least_1_dose
(
continent nvarchar(255),
location nvarchar(255),
population numeric,
at_least_1_dose numeric
)
INSERT INTO #People_with_at_least_1_dose
SELECT 
	dea.continent,
	dea.location,
	dea.population,
	MAX(CAST(vac.people_vaccinated as int)) 
	--OVER (PARTITION BY dea.location ORDER BY dea.location) 
	AS at_least_1_dose
FROM Covid_Data_Exploration..Covid_Deaths AS dea
JOIN Covid_Data_Exploration ..Covid_Vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.continent, dea.location, dea.population
--ORDER BY 2,3

SELECT *, 
	ROUND(CAST((at_least_1_dose/population)*100 AS float), 2) AS percent_vaccinated
FROM #People_with_at_least_1_dose
ORDER BY percent_vaccinated DESC


-- Creating View to store data for later visualisations
-- ������� View, ���������� ������ ��� ����������� ������������

CREATE VIEW Vaccinated_people 
AS
SELECT 
	dea.continent,
	dea.location,
	dea.population,
	MAX(CAST(vac.people_vaccinated as int)) 
	--OVER (PARTITION BY dea.location ORDER BY dea.location) 
	AS at_least_1_dose
FROM Covid_Data_Exploration..Covid_Deaths AS dea
JOIN Covid_Data_Exploration..Covid_Vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.continent, dea.location, dea.population
--ORDER BY 2,3


