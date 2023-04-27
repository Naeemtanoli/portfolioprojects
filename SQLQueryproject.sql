-- selecting data from both table to see is there any data yes there is
select top 100 * from coviddeath
select  top 100 * from [covid-vaccination]

--now select data by order from death table
select * from coviddeath
where continent is not null
order by 3,4

--selecting only data we are going to use
select location,date,population,total_cases,total_deaths
from coviddeath
order by 1,2

--now we want to see percentage of total case vs total death how many people died 
--show likelihood of dying if you are covid effected
select location,date,population,total_cases,total_deaths,
(CAST(total_deaths AS float) / CAST(total_cases AS float))*100  as perofdeath
from coviddeath
where location like '%pakistan%'
order by 1,2

--now we will se what percetange of poplution got covid from all over the world 

select location,date,population,total_cases,(cast(total_cases as float)/population)*100 as perofinfection
from coviddeath
--where location like '%united%'
order by 1,2


--now we are looking at which country has highest infection rate 

select location,population, max(cast(total_cases as int)) as highestinfectioncount,
max((cast(total_cases as float)/population))*100 as perofinfection
from coviddeath
group by location,population
order by highestinfectioncount desc


--countries with highest death rates 

select location,max(cast(total_deaths as float)) as totaldeathcount
from coviddeath
where continent is not null
group by location
order by totaldeathcount desc


--let break thing by continets
select continent,max(cast(total_deaths as float)) as totaldeathcount
from coviddeath
where continent is not null
group by continent
order by totaldeathcount desc

--again
select location,max(cast(total_deaths as float)) as totaldeathcount
from coviddeath
where continent is  null
group by location
order by totaldeathcount desc

--showing the content with highest death coutns
--global numbers

select sum(new_cases) as newcases,sum(new_deaths) as newdeaths,
(sum(new_deaths+0.1)/sum(new_cases+0.1))-0.1 as centageofdeath
from coviddeath
where continent is not null
--group by date
order by 1,2




--after joining both the tables

select * from coviddeath as dea
join [covid-vaccination] as vac
on dea.location =vac.location
and dea.date= vac.date
order by 3,4

--looking at total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as new
from coviddeath as dea
join [covid-vaccination] as vac
on dea.location =vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3


-- this is time is for real show

with popvsvac(continent,location,date,population,new_vaccinations,rollingpeoplvaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as 
rollingpeoplvaccinated
from coviddeath as dea
join [covid-vaccination] as vac
on dea.location =vac.location
and dea.date= vac.date
where dea.continent is not null
)
select *,(rollingpeoplvaccinated/population)*100
from popvsvac


--tempt tables
drop table if exists #percentofpeoplevaccinated
create table #percentofpeoplevaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplvaccinated numeric
)
insert into  #percentofpeoplevaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as 
rollingpeoplvaccinated
from coviddeath as dea
join [covid-vaccination] as vac
on dea.location =vac.location
and dea.date= vac.date
where dea.continent is not null

select *,(rollingpeoplvaccinated/population)*100
from #percentofpeoplevaccinated

-- creating view for store data to use in later vizulizations

create view percentofpeoplevaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as 
rollingpeoplvaccinated
from coviddeath as dea
join [covid-vaccination] as vac
on dea.location =vac.location
and dea.date= vac.date
where dea.continent is not null

select * from percentofpeoplevaccinated

