-- Taking a peek at the Global_Health_Statistics Table
select * From Global_Health_Statistics

-- Total Population Affected By Disease
 Select Country, Disease_Name, Sum(Population_Affected) As Population_Affected
From Global_Health_Statistics
Group By Country, Disease_Name
Order By Country, Disease_Name



-- Total Mortality Rate By Gender
Select Country, Gender, [Year], Sum(Mortality_Rate / Population_Affected) * 100 As Mortality_Rate
 From Global_Health_Statistics
 group By Country,[Year], Gender
 Order by Country



 --Total Recovery Rate By Gender
Select Country, Gender, Round(Sum(Recovery_Rate / Population_Affected) * 100, 1) As Rate
 From Global_Health_Statistics
 group By Country, Gender
 Order by Country



 --Can The Population Afford The Bills Based On Disease By Category
 Select Country, Year, Disease_Name, Disease_Category, Per_Capita_Income_USD, Average_Treatment_Cost_USD, (Average_Treatment_Cost_USD - Per_Capita_Income_USD) As Income_minus_avg_treatment,
 Case 
 When Per_Capita_Income_USD > Average_Treatment_Cost_USD Then 'Yes'
  When Per_Capita_Income_USD < Average_Treatment_Cost_USD Then 'No'
   When Per_Capita_Income_USD = Average_Treatment_Cost_USD Then 'Perfect'
   Else 'None'
   End As Treatment_Payment
From Global_Health_Statistics
Group by Country, Year, Disease_Name, Disease_Category, Per_Capita_Income_USD, Average_Treatment_Cost_USD, Per_Capita_Income_USD



--Population Vs Recovery Rate
With Cte_Rate (Country, [Population], Recovery_Rate, Recovery_Percent) As
	(Select  Country, Population_Affected, Recovery_Rate, ( Recovery_Rate / 100)
			From Global_Health_Statistics)
	Select Country, [Population], Recovery_Rate, Recovery_Percent, Round(([Population] * Recovery_Percent),1) As Population_Recovered  From Cte_Rate
	Order by 1




-- Affected Population Who Have Access to Hospital Bed
  With HospitalBed
	As
		( Select Country, [Year], Population_Affected, Hospital_Beds_per_1000, (Hospital_Beds_per_1000 / 1000 ) As Hospital_Beds
		From Global_Health_Statistics)
		Select *, (Population_Affected  * Hospital_Beds) AS Access_To_Hospital_bed From HospitalBed
		Order by 1, 2

-- This analysis uses CTE to show the available number of beds that are made available to the Population Affected




 -- Available Doctors who are accssible to the Affected Population
 select *,( Population_Affected * Doctors_Percent_Per_1000) As Access_To_Doctor
 From  (Select Country, [Year], Population_Affected, Doctors_Per_1000, (Doctors_Per_1000 / 1000 )  As Doctors_Percent_Per_1000
 From Global_Health_Statistics) as Doctors_Per_1000
 Order by Country, [Year]

 -- This analysis uses Derived Table to show the Numbers of Doctors the Population Affected can access




 --Access To Health_Care
Declare @Health_Care
Table (Country nvarchar(50), [Year] Int, Population_Affected Int, Healthcare_Access Float)
Insert into @Health_Care
Select Country, [Year], Population_Affected, Healthcare_Access From Global_Health_Statistics
	Order by Country, [Year]

Select *, (Healthcare_Access / 1000) * Population_Affected As Hospital_Care From @Health_Care
Order by Country, [Year]

-- This analysis uses Table Variable to show the Numbers of Health Care available to the Affected Population


-- The number of urbanized citizens
Create Table #Urbanization_Rate 
(Country Nvarchar(50), 
[Year] Int,
Population_Affected Int,
Urbanization_Rate Float)

Insert into #Urbanization_Rate 
Select Country, [Year], Population_Affected, Urbanization_Rate, Round((Urbanization_Rate / 100) * Population_Affected, 0) As Urbanization from #Urbanization_Rate 

-- This analysis creates a Temp Table which was use to get the number of urbanization Rate
