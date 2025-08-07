-- Taking a peek at the Global_Health_Statistics Table
Select * From Global_Health_Statistics


--Total Distinct Countries
Select Distinct Country From Global_Health_Statistics



-- Total Population Affected By Disease
Select Country, Disease_Name, Sum(Population_Affected) As Population_Affected
From Global_Health_Statistics
Group By Country, Disease_Name
Order By Country, Disease_Name



--Created view for further queries
Alter view Patient_Survival
as
Select Country, [Year], Mortality_Rate, Recovery_Rate, Population_Affected, Sum(Per_Capita_Income_USD) As Per_Capita, Sum(Average_Treatment_Cost_USD) As Average_Treatment_Cost,
 Case 
 When Per_Capita_Income_USD > Average_Treatment_Cost_USD Then 'Yes'
 When Per_Capita_Income_USD < Average_Treatment_Cost_USD Then 'No'
 When Per_Capita_Income_USD = Average_Treatment_Cost_USD Then 'Perfect'
 Else 'None'
 End As Treatment_Payment
From Global_Health_Statistics
Group By Country, [Year], Mortality_Rate, Recovery_Rate, Population_Affected, Per_Capita_Income_USD, Average_Treatment_Cost_USD



-- Mortality Rate By Country and Year
Select Country, [Year], Sum(Population_Affected) As Population_Affected, Round(Sum(Population_Affected * Mortality_Rate) / 100 , 0) As Total_Mortality
From Patient_Survival
Where Country = 'Nigeria'
Group By Country, [Year] 
Order by Year
Order By Total_Mortality Desc




 --Total Recovery Rate By Gender
Select Country, [Year], Sum(Population_Affected) As Population_Affected, Round(Sum(Population_Affected * Recovery_Rate) / 100, 0) As Total_Recovery
From Patient_Survival
Group By Country, [Year]
Order By Total_Recovery Desc



--Population Vs Recovery Rate
With Cte_Rate 
As
(Select  Country, Disease_Name, [Year], Population_Affected, Recovery_Rate, ( Recovery_Rate / 100) As Recovery_Percent
From Global_Health_Statistics)
Select Country, Disease_Name, [Year], Population_Affected, Recovery_Rate, Round((Population_Affected * Recovery_Percent),1) As Population_Recovered  From Cte_Rate
Where Country = 'Nigeria'
Order by [Year]




-- Affected Population Who Have Access to Hospital Bed
With Hospital_Bedz
As
(Select Country, [Year], Hospital_Beds_per_1000, (Hospital_Beds_per_1000 / 1000 ) * Population_Affected As Total_Hospital_Bed
From Global_Health_Statistics
Group by Country, Hospital_Beds_per_1000,[Year], Population_Affected)
Select Country, [Year], Hospital_Beds_per_1000, Sum(Total_Hospital_Bed) As Total_Hospital_Bed From Hospital_Bedz
Where Country = 'Nigeria'
Group by Country, Hospital_Beds_per_1000, [Year]
Order by 2 Desc




 -- Available Doctors who are accessible to the Affected Population
 Select Country, [Year], Sum(Population_Affected) As Population_Affected, ( Population_Affected * Doctors_Percent_Per_1000) As Access_To_Doctor
 From  (Select Country, [Year], Population_Affected, (Doctors_Per_1000 / 1000 ) * 100  As Doctors_Percent_Per_1000
 From Global_Health_Statistics) as Doctors_Per_1000
 Where Country = 'Nigeria'
 Group by Country, [Year], Population_Affected, Doctors_Percent_Per_1000
 Order by Access_To_Doctor, Population_Affected Desc
-- This analysis uses Derived Table to show the Numbers of Doctors the Population Affected can access




 --Access To Health_Care
Declare @Health_Care
Table (Country nvarchar(50), 
[Year] Int, 
Population_Affected Int, 
Healthcare_Access Float)

Insert Into @Health_Care
Select Country, [Year], Population_Affected, Healthcare_Access From Global_Health_Statistics
Order By Country, [Year]

Select *, (Healthcare_Access / 1000) * Population_Affected 
As Hospital_Care From @Health_Care
Where COuntry = 'Nigeria'
Order By Country, [Year]
-- This analysis uses Table Variable to show the Numbers of Health Care available to the Affected Population




-- Rate of  Urbanization
Create Table #Urbanization_Rate 
(Country Nvarchar(50), 
[Year] Int,
Population_Affected Int,
Urbanization_Rate Float)

Insert into #Urbanization_Rate 
Select Country, [Year], Population_Affected, Urbanization_Rate, (Urbanization_Rate / 100) * Population_Affected As Urbanization from Global_Health_Statistics 

-- This analysis creates a Temp Table which was use to get the number of urbanization Rate
select * from #Urbanization_Rate;
truncate table #Urbanization_Rate



--Knowing the highest Mortality Rate and it causes 
With Mortality_by_Disease 
As
(
select Country, Age_Group, Disease_Name, mortality_rate, Count(mortality_rate) As Total_Mortality from Global_Health_Statistics
Group by Country, Age_Group, Disease_Name, mortality_rate
)
Select Top 1 Country, Age_Group, Disease_Name, mortality_rate, max(Total_Mortality) As Total_Mortality from Mortality_by_Disease
Where Country = 'Nigeria'
Group by Country, Age_Group, Disease_Name, mortality_rate
Order by Total_Mortality Desc


