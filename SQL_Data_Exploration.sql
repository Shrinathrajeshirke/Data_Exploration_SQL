--Covid vaccination data
select * from Covid_vaccination$

--Covid deaths data
select * from Covid_deaths$

--requird data

select location, date, total_cases, new_cases, total_deaths, population
from Covid_deaths$
order by 1,2

--Total cases vs total deaths
--Likelihood of dying if you contract covid in your country
select location, date, total_cases, new_cases, total_deaths, round((total_deaths/total_cases)*100,2) as Deathpercentage
from Covid_deaths$
order by 1,2

--Total cases vs total deaths in India
--Likelihood of dying if you contract covid in India
select location, date, total_cases, new_cases, total_deaths, round((total_deaths/total_cases)*100,2) as Deathpercentage
from Covid_deaths$
where location like 'India'
order by 1,2

--Total cases vs population
--shows the percentage of the population got covid
select location, date, total_cases, new_cases, population, round((total_cases/population)*100,4) as Deathpercentage
from Covid_deaths$
where location like 'India'
order by 1,2

--Highest infected country compared to population
select location, population, max(total_cases) as highinfectioncount, Max(round((total_cases/population)*100,4)) as percentagepopinfected
from Covid_deaths$
group by location, population
order by percentagepopinfected desc

--Highest died peoples country per population
select location, max(cast(total_deaths as int)) as totaldeathcount
from Covid_deaths$
where continent is not null
group by location
order by totaldeathcount desc

--Highest died people by continent
--Showing continent with highest death count
select continent, max(cast(total_deaths as int)) as totaldeathcount
from Covid_deaths$
where continent is not null
group by continent
order by totaldeathcount desc

--Global numbers
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
round((sum(cast(new_deaths as int))/sum(new_cases))*100,2) as Deathpercentage
from Covid_deaths$
where continent is not null
group by date
order by 1,2

--Total global deaths percentage
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
round((sum(cast(new_deaths as int))/sum(new_cases))*100,2) as Deathpercentage
from Covid_deaths$
where continent is not null
order by 1,2

--Join covid_deaths and covid_vaccination
--Total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as people_vaccinated
From Covid_deaths$ as dea
join Covid_vaccination$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

with popvsvac (continent, location, date, population,new_vaccinations, people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as people_vaccinated
From Covid_deaths$ as dea
join Covid_vaccination$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (people_vaccinated/population)
from popvsvac

--creating view to sotre data for visualizations

create view percentpopvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as people_vaccinated
From Covid_deaths$ as dea
join Covid_vaccination$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from percentpopvaccinated
