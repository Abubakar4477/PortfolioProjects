select*
from SQL_Portfolio..CovidDeaths
order by 3,4

--select*
--from SQL_Portfolio..CovidVaccinations
--order by 3,4


select Location, date, total_cases, new_cases, total_deaths, population
from SQL_Portfolio..CovidDeaths
order by 1,2
