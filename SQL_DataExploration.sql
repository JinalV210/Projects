select * from CovidVaccination
where continent is not null
order by location , date desc


select * from CovidDeaths
where continent is not null
order by location , date desc




select location , date , total_cases , total_deaths  , population
from Portfolio_projects..CovidDeaths
where continent is not null
order by 1 ,2 


--looking for total cases VS total death


select location , date , total_cases , total_deaths  , 
(cast(total_deaths as float)/cast(total_cases as float))* 100 as Death_percentage  
from Portfolio_projects..CovidDeaths
where location ='India'
and continent is not null
order by 1 ,2  


-----------------Looking at total cases VS population


select location , date , total_cases ,  population ,
(cast(total_cases as float)/cast(population as float))* 100 as Death_percentage  
from Portfolio_projects..CovidDeaths
where location ='India'
and continent is not null
order by 1 ,2  desc


-----------------Looking at countries with highest infection rate  compared to population------------


select  location , population , MAX(total_cases) as Highestinfectioncount , Max((total_cases/population)) * 100 as percentpopulationinfected
from Portfolio_projects..CovidDeaths
where continent is not null
group by location , population
order by percentpopulationinfected desc


----------showing countries with highest death population---------

select  location , max(cast(total_deaths as int)) as Total_death_count
from Portfolio_projects..CovidDeaths
where continent is not null
group by location
order by Total_death_count desc


---------------------highest death population by continent wise-----------------------------


select  continent , max(cast(total_deaths as int)) as Total_death_count
from Portfolio_projects..CovidDeaths
where continent is not null
group by continent
order by Total_death_count desc


-----correct data because continent coloumn is null-- NO NEED TO INCLUDE---------------

select  location , max(cast(total_deaths as int)) as Total_death_count
from Portfolio_projects..CovidDeaths
where continent is  null
group by location
order by Total_death_count desc


-------------------------Global number----------------------

select  sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths  , sum(cast(new_deaths as int))/SUM(new_cases)* 100 as Death_percentage  
from Portfolio_projects..CovidDeaths
--where location ='India'
where continent is not null
--group by  date
order by 1 ,2  

------------------looking for total population VS vaccination--------------------------------------------------------------------

select dea.continent , dea.location  , dea.date , dea.population , vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location , dea.date) as NoofpeopleVaccinated
----, (NoofpeopleVaccinated/dea.population) * 100
from Portfolio_projects..CovidDeaths dea
join Portfolio_projects..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2 , 3



 -------USE CTE-----------

 With PopvsVac (continent , location , date , population ,new_vaccinations , NoofpeopleVaccinated)
 as
 (
select dea.continent , dea.location  , dea.date , dea.population , vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location , dea.date) as NoofpeopleVaccinated
----, (NoofpeopleVaccinated/dea.population) * 100
from Portfolio_projects..CovidDeaths dea
join Portfolio_projects..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
--- order by 2 , 3
 )

 select * , (NoofpeopleVaccinated/population) * 100
 from PopvsVac



 -------------------------------------TEMP TABLE-----------------------

drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar(255),
date  datetime,
population numeric ,
new_vaccinations numeric,
NoofpeopleVaccinated numeric

)
Insert into #PercentPopulationVaccinated
 select dea.continent , dea.location  , dea.date , dea.population , vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location , dea.date) as NoofpeopleVaccinated
----, (NoofpeopleVaccinated/dea.population) * 100
from Portfolio_projects..CovidDeaths dea
join Portfolio_projects..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
--- order by 2 , 3

 select * , (NoofpeopleVaccinated/population) * 100 as percentpeoplevaccinated
 from #PercentPopulationVaccinated


 ------------------------------------------------------------------------------------------------


 -----------Cretae view to store data for Visulation-------------

 Create view percentpopulationvaccinated as
 select dea.continent , dea.location  , dea.date , dea.population , vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location , dea.date) as NoofpeopleVaccinated
----, (NoofpeopleVaccinated/dea.population) * 100
from Portfolio_projects..CovidDeaths dea
join Portfolio_projects..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
--- order by 2 , 3

--------------------------------
select * from
percentpopulationvaccinated