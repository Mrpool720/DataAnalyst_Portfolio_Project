Select * 
 From PortfolioProject..CovidDeaths
 Where continent is not null
 Order By 3, 4

 --Select * 
 --From PortfolioProject..CovidVaccinations
 --Where continent is not null
 --Order By 3, 4

-- Data that are going to use in the project.
Select location, date, total_cases, new_cases, total_deaths, population
 From PortfolioProject..CovidDeaths
 Where continent is not null
 Order By 1, 2

 -- Total cases vs Total Deaths 
 Select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 As DeathPercent
 From PortfolioProject..CovidDeaths
 Where location like '%india%'
 and continent is not null
 Order By 1, 2

  -- Total cases vs Population
 Select location, date,  population, total_cases, (total_cases/population) * 100 As PercentInfectedPopulation
 From PortfolioProject..CovidDeaths
 Where location like '%india%'
 Order By 1, 2

 -- Countries with Highest Infected Rate compared with Population
 Select location,  population, Max(total_cases) As HighestInfectionCount, Max((total_cases/population)) * 100 As InfectedPopulationPercent
 From PortfolioProject..CovidDeaths
 --Where location like '%india%'
 Group By location, population
 Order By InfectedPopulationPercent desc

 -- Countries with Highest Death Count per Population
 Select location,  Max(Cast(total_deaths as int)) As TotalDeathCount
 From PortfolioProject..CovidDeaths
 Where continent is not null
 Group By location
 Order By TotalDeathCount desc


-- Break Down By Continent

-- Continents with the highest Death by Count by Population
Select continent,  Max(Cast(total_deaths as int)) As TotalDeathCount
 From PortfolioProject..CovidDeaths
 Where continent is not null
 Group By continent
 Order By TotalDeathCount desc

 -- Continent with Highest Infected Rate compared with Population
 Select continent, Max(total_cases) As HighestInfectionCount, Max((total_cases/population)) * 100 As InfectedPopulationPercent
 From PortfolioProject..CovidDeaths
 --Where location like '%india%'
 Where continent is not null
 Group By continent
 Order By InfectedPopulationPercent desc

 -- Total cases vs Total Deaths 
 Select continent, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 As DeathPercent
 From PortfolioProject..CovidDeaths
 Where continent is not null
 Order By 1, 2


-- Global Number
Select Sum(new_cases) As total_cases, Sum(Cast(new_deaths As int)) as total_deaths, Sum(Cast(
	new_deaths as int)) / Sum(new_cases)*100 
  As DeathPercent
 From PortfolioProject..CovidDeaths
 --Where location like '%india%'
 Where continent is not null
 --Group By date
 Order By 1, 2


-- Joining Both Tables (CovidDeath and CovidVaccinations)
Select * 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date

-- Total Population vs Vaccinations
-- CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinatedPeople)
As 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Convert(int, vac.new_vaccinations)) Over (Partition By dea.location Order by dea.location,
	dea.date) as RollingVaccinatedPeople
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
)
Select *, (RollingVaccinatedPeople/Population) * 100 As Vaccinated
 From PopvsVac


-- Creating Temp Table
Drop Table If Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingVaccinatedPeople numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Convert(int, vac.new_vaccinations)) Over (Partition By dea.location Order by dea.location,
	dea.date) as RollingVaccinatedPeople
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
Select *, (RollingVaccinatedPeople/Population) * 100 As Vaccinated
 From #PercentPopulationVaccinated


-- Creating a View to store data for visulizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Convert(int, vac.new_vaccinations)) Over (Partition By dea.location Order by dea.location,
	dea.date) as RollingVaccinatedPeople
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3