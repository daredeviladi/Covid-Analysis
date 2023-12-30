

SELECT *
FROM PortfolioProject1..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject1..CovidVaccinations$
--ORDER BY 3,4

--SELECTING DATA

SELECT location , date , total_cases , new_cases , total_deaths , population
FROM PortfolioProject1..CovidDeaths$
ORDER by 1,2



--TOTAL CASES VS TOTAL DEATHS
--SHOWS LIKELIHOOD OF DYING IF YOU WILL GET INFECTED 

SELECT location , date , total_cases  , total_deaths , population ,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths$
WHERE location like 'india'
AND continent is not null
ORDER by 1,2



--HOW MANY PERCENTAGE OF PEOPLE GOT INFECTED VS DATE

SELECT location , date , total_cases  , total_deaths , population , ROUND((total_cases/population)*100,2) AS TotalCasePercentage
FROM PortfolioProject1..CovidDeaths$
WHERE location like 'india'
AND continent is not null
ORDER by 1,2



--countries with highest infection rate compared to Populations

SELECT
	location,
    population,
    MAX(total_cases) as HighestInfectionCount,
    (MAX(total_cases) / population) * 100 AS MaxPopulationCasePercentage
FROM
    PortfolioProject1..CovidDeaths$
GROUP BY
	location , population
ORDER BY
    MaxPopulationCasePercentage DESC;

--Showing Countries AND continents with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject1..CovidDeaths$
GROUP BY location 
ORDER BY TotalDeathsCount DESC;


--Showing the continent having maximum death counth


SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject1..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount DESC;

--THERE are issues in dataa



--Global DATA extraction

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  AS DeathPercentage
FROM PortfolioProject1..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER by 1,2



Select *
FROM PortfolioProject1..CovidVaccinations$

--Joining both the tables 
Select *
From PortfolioProject1..CovidDeaths$ as dea
join PortfolioProject1..CovidVaccinations$ as vac
	ON dea.location = vac.location AND dea.date = vac.date




--USE CTE
WITH PopVsVac(Continent , location , Date , population ,new_vaccinations, RollingPeopleVaccinationated) --CTE
as
(

--Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date , population , vac.new_vaccinations ,
SUM( CONVERT(int ,vac.new_vaccinations )) over (Partition by dea.location Order by  dea.location , dea.date) as RollingPeopleVaccinationated
--(RollingPeopleVaccinationated/population)*100
From PortfolioProject1..CovidDeaths$ as dea
join PortfolioProject1..CovidVaccinations$ as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null 
--Order BY 2,3
)
--Select * , (RollingPeopleVaccinationated / population)*100 as PercentageRollingPeopleVaccinationated
--From PopVsVac;
--This is It but now more EDA

Select * , (RollingPeopleVaccinationated / population)*100 as PercentageRollingPeopleVaccinationated
From PopVsVac;




--USING TEMP TABLE
DROP table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime ,
new_vaccination numeric ,
Population numeric ,
RollingPeopleVaccinationated numeric
)
--Looking at Total Population vs Vaccination
INSERT into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date , population , vac.new_vaccinations ,
SUM( CONVERT(int ,vac.new_vaccinations )) over (Partition by dea.location Order by  dea.location , dea.date) as RollingPeopleVaccinationated
--(RollingPeopleVaccinationated/population)*100
From PortfolioProject1..CovidDeaths$ as dea
join PortfolioProject1..CovidVaccinations$ as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null 

Select * , (RollingPeopleVaccinationated / Population)*100 as PercentageRollingPeopleVaccinationated
From #PercentagePopulationVaccinated;



--Creating View to Store Data for later Visualisation

Create View PercentagePopulationVaccinatedView as 
Select dea.continent, dea.location, dea.date , population , vac.new_vaccinations ,
SUM( CONVERT(int ,vac.new_vaccinations )) over (Partition by dea.location Order by  dea.location , dea.date) as RollingPeopleVaccinationated
--(RollingPeopleVaccinationated/population)*100
From PortfolioProject1..CovidDeaths$ as dea
join PortfolioProject1..CovidVaccinations$ as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null 
--Order BY 2,3


Select* 
FROM PercentagePopulationVaccinatedView