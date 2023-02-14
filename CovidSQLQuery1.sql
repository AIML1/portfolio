select *
from portfolioproject..CovidDeaths
order by 3,4


--select *
--from portfolioproject..Covidvacc
--order by 3,4

-- select data that we are going to be using 
select location,DATE,total_cases,new_cases,total_deaths,population
from portfolioproject..CovidDeaths
order by 1,2
--looking at total cases vs total deaths
-- India tottal death percentage
select location,DATE,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..CovidDeaths
where location like '%India%'
order by 1,2

--looking at total cases vs population
--population got covid
select location,DATE,total_cases,population,(total_cases/population)*100 as deathpercentage
from portfolioproject..CovidDeaths
where location like '%India%'
order by 1,2

--looking at countries with highest infection rate compared to population
select location,population,Max(total_cases)as highestinfectioncount,max(total_cases/population)*100 as perpopulationinfected
from portfolioproject..CovidDeaths
group by location,population
order by perpopulationinfected desc


--showing countries with highest death count
select location, max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc


--Let's break things down by continent
select location, max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..CovidDeaths
where continent is null
group by location
order by totaldeathcount desc


--global numbers

select date,SUM(new_cases),SUM(CAST(new_deaths as int)) as deathpercentage
from portfolioproject..CovidDeaths
where continent is not null
group by date 
order by 1,2

--global numbers
select SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from portfolioproject..CovidDeaths
where continent is not null
--group by date 
order by 1,2



select location,DATE,total_cases,new_cases,total_deaths,population
from portfolioproject..CovidDeaths
order by 1,2

--looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..Covidvacc vac
	on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null
	order by 2,3	

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 