                                                   /***** COVID PROJECT *****/
	



-- total cases vs total deaths
-- it's shows percent of dying chance if u're infected by covid
select location,date,total_cases,total_deaths,concat(round((total_deaths / total_cases *100),2), ' %') as Death_percentage
from CovidDeaths$
where location like 'austria'           -- (1.65% of dying chance in Austria (last day 30 April))
order by 1,2	


-- total cases vs total population
-- it's shows percent of population infected by covid 
select location,date,population,total_cases,
concat(round((total_cases / population *100),2), ' %') as infected_percent
from CovidDeaths$
where location not in ('asia','south america','north america','europe','africa','europe','oceania','world','european union')           
order by 1,2	


-- which countries have the highest infected rate compared to population
select location,population,MAX(total_cases) as totalcases,
concat(round((max(total_cases / population*100)),2),' %') as high_infected_rate 
from CovidDeaths$
where location not in ('asia','south america','north america','europe','africa','europe','oceania','world','european union')
group by location,population
order by high_infected_rate desc


--which countries have the highest death rate per population
select location,MAX(cast(total_deaths as int)) as totaldeath
from CovidDeaths$
where location not in ('asia','south america','north america','europe','africa','europe','oceania','world','european union')
group by location
order by totaldeath desc


-- which continents have the highest death rate 
select continent,max(cast(total_deaths as int)) as totaldeath_in_continent
from CovidDeaths$
where continent is not null
group by continent
order by totaldeath_in_continent

--global number
select sum(new_cases),sum(convert(int,new_deaths))as totaldeaths,
concat(round((sum(convert(int,new_deaths))/sum(new_cases) *100),2),' %') as death_percentage 
from CovidDeaths$
where continent is not null
order by 1,2


--total population vs total vaccination
select de.continent,de.location,de.date,de.population,va.new_vaccinations,
sum(convert(int,va.new_vaccinations)) over(partition by de.location order by de.location,de.date) as rollingvaccine
from CovidDeaths$ de
join CovidVaccinations$ va
on de.location=va.location  and de.date=va.date
where de.continent is not null
order by 2,3


          -- (USING CTE)
--looking AT how many peoples are vaccinated  

with cte as (select de.continent,de.location,de.date,de.population,va.new_vaccinations,
sum(convert(int,va.new_vaccinations)) over(partition by de.location order by de.location,de.date) as rollingvaccine
from CovidDeaths$ de
join CovidVaccinations$ va
on de.location=va.location  and de.date=va.date
where de.continent is not null)
select *,concat(round(rollingvaccine/population*100,2),' %') as deathpercentage
from cte


           --(USING TEMP TABLE)
--looking AT how many peoples are vaccinated 

drop table if exists #percentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccine numeric)

Insert into #PercentPopulationVaccinated select de.continent,de.location,de.date,de.population,va.new_vaccinations,sum(convert(int,va.new_vaccinations)) 
over(partition by de.location order by de.location,de.date) as RollingVaccine
from CovidDeaths$ de
join CovidVaccinations$ va
on de.location=va.location  and de.date=va.date
where de.continent is not null


select *,concat(round(RollingVaccine/population*100,2),' %') as deathpercentage
from #PercentPopulationVaccinated

--  creating VIEWS to store data for later visualization

create view peoplevaccinated as
select de.continent,de.location,de.date,de.population,va.new_vaccinations,sum(convert(int,va.new_vaccinations)) 
over(partition by de.location order by de.location,de.date) as RollingVaccine
from CovidDeaths$ de
join CovidVaccinations$ va
on de.location=va.location  and de.date=va.date
where de.continent is not null