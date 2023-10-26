
--------------------------------------------------------------------------------Covid-19--------------------------------------------------------------------------------


-- data we working with in CovidDeathes table

select location ,date ,total_cases,new_cases,total_deaths , population from CovidDeaths where continent is not null order by 1 ,2 

/* total cases vs total  death in Morroco 
 likelihood of dying if you contract covid in Morocco  */


select location,date ,total_cases ,total_deaths , (convert(float,total_deaths)/convert(float,total_cases)) * 100  as 

DeathPercentage from  CovidDeaths where location ='Morocco' and (convert(float,total_deaths)/convert(float,total_cases)) * 100 is not null ORDER BY 1, 2 ;

--- What percentage of the population has been infected with Covid in Morocco ?


select location,date ,total_cases ,population , (convert(float,total_cases)/population) * 100  as 

AffectionPercentage from  CovidDeaths where location ='Morocco' and (convert(float,total_cases)/convert(float,population)) * 100  is not null  ORDER BY 1, 2 ;

-- countries with the highest infection rate compared to the population

select location ,population , Max(Total_cases) as TotalCasesNumber,	 Max((convert(float,total_cases)/population ) * 100)  as 

AffectionPercentage from  CovidDeaths where continent is not null group by  location ,population      ORDER BY AffectionPercentage desc ;  

----- countries with the highest death count 


 select location , Max(total_deaths) as Deaths from CovidDeaths  where continent is not null group by location order by 2 desc 

 ---- Continents with the highest death count 

 select location as Continent , Max(total_deaths) as Deaths from CovidDeaths  where continent is  null group by location order by 2 desc 

 -----------------    cases and deaths per day in the world  

 select date , sum (new_cases)  as 

Totalcases ,sum(new_deaths) as TotalDeaths , (sum(new_deaths)/sum(population))* 100 as WorldPercentageOfDeath from  CovidDeaths  where Continent is not null group by date  ORDER BY 1 ;

--------------------- total population vs vaccination in the world

select cd.continent,cd.location ,cd.date, cd.population ,cv.total_vaccinations ,

(cv.total_vaccinations/cd.population)* 100 as PercentageOfVaccinatedPeople from CovidDeaths Cd join 

CovidVaccinations cv on cd.location = cv.location  and cd.date = cv.date  order  by 1,2

----------------  showing the  total vaccinations + New Vaccinations per day

select cd.continent,cd.location ,cd.date, cd.population ,cv.new_vaccinations , sum(convert(float,cv.new_vaccinations) ) 

over (partition by cd.location  order by cd.location , cd.date) as totalVaccinations  from CovidDeaths Cd join 

CovidVaccinations cv on cd.location = cv.location  and cd.date = cv.date where cd.continent is not null  and cv.new_vaccinations 

is not null order  by 1,2,3

-------------  Using CTE to perform Calculation on Partition By in previous query

with test as (select cd.continent,cd.location ,cd.date, cd.population ,cv.new_vaccinations , sum(convert(float,cv.new_vaccinations) ) 

over (partition by cd.location  order by cd.location , cd.date) as totalVaccinations  from CovidDeaths Cd join 

CovidVaccinations cv on cd.location = cv.location  and cd.date = cv.date where cd.continent is not null  and cv.new_vaccinations 

is not null )

select *  , (totalVaccinations/population) * 100 from test order by 2 ,3

-------------  total population vs vaccination in the world using temp tables for later Queries 

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(Continent varchar(50),location varchar(50),Date date,Population float,VaccinationPerDay float,TotalVaccination float)

insert into #PercentPopulationVaccinated  
select cd.continent,cd.location ,cd.date, cd.population ,cv.new_vaccinations , sum(convert(float,cv.new_vaccinations) ) 

over (partition by cd.location  order by cd.location , cd.date) as totalVaccinations  from CovidDeaths Cd join 

CovidVaccinations cv on cd.location = cv.location  and cd.date = cv.date where cd.continent is not null  and cv.new_vaccinations 

is not null 

select *  , (TotalVaccination/Population) * 100 from  #PercentPopulationVaccinated  order by 2 ,3