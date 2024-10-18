use healthycare;


select * from healthy

-- 1. Counting total record in database
select count(*) from healthy

-- 2. finding maximum age of patient admitted
select max(age) as Maximum_Age from healthy

-- 3. finding maximum age of hospitalized patients.
select round(avg(age),0) as Average_Age from healthy

-- 4. calculating patient hospitalized age-wise from maximum to minimum
select AGE, count(AGE) as Total from healthy
group by AGE
order by AGE desc
	-- finding the output will display a list of unique ages present in the "healthycare" table along with the count of occurrences for each age, sorted from oldes to youngest.

-- 5. calculating maximum count of patients on basis of total patients hospitalized with respect to age.
select age, count(age) as total from healthy
group by age 
order by total desc, age desc

-- 6. ranking age on the number of patients hospitalized
select age, count(age) as total, dense_rank() over(order by count(age) desc, age desc) as Ranking_Admitted
from healthy
group by age
having total > Avg(age)

-- 7.  Finding Count of Medical Condition of patients and lisitng it by maximum no of patients.
select Medical_Condition, count(Medical_Condition) as Total_Patients from healthy
group by Medical_Condition
order by Total_Patients desc
	--  Findings : This query retrieves a breakdown of medical conditions recorded in a healthcare dataset along with the total number of patients diagnosed with each condition. It groups the data by distinct medical conditions, counting the occurrences of each condition across the dataset. The result is presented in descending order based on the total number of patients affected by each medical condition, providing an insight into the prevalence or frequency of various health issues within the dataset

-- 8. Finding Rank & Maximum number of medicines recommended to patients based on Medical Condition pertaining to them
select distinct Medical_Condition, Medication,count(Medication) as total_Medications_to_patients,rank() over(partition by Medical_Condition order by count(Medication) desc) as Rank_Medicine
 from healthy
group by 1,2
order by 1
	-- Finding : The output provides insight into the most common medications used for various medical conditions, assigning a rank to each medication based on how frequently its prescribed within its corresponding condition.

-- 9. Most preffered Insurance Provide  by Patients Hospatilized
select Insurance_Provider, count(Insurance_Provider) as total
from healthy
group by Insurance_Provider
order by total desc
	-- Findings : This information helps identify the most prevalent insurance providers among the patient population, offering valuable data for resource allocation, understanding coverage preferences, and potentially indicating trends in healthcare accessibility based on insurance networks

-- 10.finding out most preffered hospital
select Hospital, count(Hospital) as Total
from healthy
group by Hospital
order by Total desc    
	-- Findings : It provides insight into which hospitals have the highest frequency of records within the healthcare dataset. The resulting list showcases hospitals based on their patient count or the number of entries related to each hospital, allowing for an understanding of the distribution or prominence of healthcare services among different medical facilities.

-- 11. identifying average billing amount by medical condition.
select Medical_Condition , Round(avg(Billing_Amount),2) as  avg_Bill_amount
from healthy
group by Medical_Condition
	-- Findings :  It offers insights into the typical costs associated with various medical conditions. This information can be valuable for analyzing the financial impact of different health issues, identifying expensive conditions, or assisting in resource allocation within healthcare facilities.

-- 12. finding billing amount of patients admitted and number of days spent in respective hospital.
select Medical_Condition, Name, Hospital, DATEDIFF(Discharge_Date,Date_of_Admission) as Number_of_Days,
sum(round(Billing_Amount,2)) over(partition by Hospital order by Hospital Desc) as Total_Amount
from healthy
order by Medical_Condition

-- 13. Finding Total number of days sepnt by patient in an hospital for given medical condition
select Name,Medical_Condition,Round(Billing_Amount,2) as Billing_Amount, Datediff(Discharge_Date,Date_of_Admission) as Total_Hospitalized_days
from healthy
	-- Findings : This query retrieves a dataset showing the names of patients, their respective medical conditions, billed amounts (rounded to two decimal places), the hospitals they visited, and the duration of their hospital stay in days. Insights gleaned include: 
		-- Individual Patient Details: It presents a comprehensive view of patients, their medical conditions, billed amounts, and hospitals involved, aiding in understanding the scope of medical services availed by patients.
		-- Financial Overview: The rounded billing amounts provide an overview of the costs incurred by patients for their treatments, assisting in analyzing the financial aspect of healthcare services.
		-- Hospital Performance: By knowing the length of hospital stays, an evaluation of the efficiency of hospitals in managing patient care and treatment duration is possible.
		-- Potential Patterns: Patterns in medical conditions, billed amounts, and duration of hospitalization may emerge, offering insights into prevalent health issues and associated costs in the healthcare dataset.

-- 14. Finding Hospitals which were successful in discharging patients after having test results as 'Normal' with count of days taken to get results to Normal
select Medical_Condition,Hospital,Datediff(Discharge_Date,Date_of_Admission) as total_hopitalized_days,Test_results
from healthy
where Test_results Like'Normal'
order by Medical_Condition,Hospital

-- 15. Calculate number of blood types of patients which lies betwwen age 20 to 45
select Age,Blood_type,count(Blood_type) as Count_Blood_Type
from healthy
where Age between 20 and 45
group by 1,2
order by Blood_Type desc
	-- Findings: This query filters healthcare data for individuals aged between 20 and 45, grouping them by their age and blood type. It then counts the occurrences of each blood type within this age range. The output provides a breakdown of blood type distribution among individuals aged 20 to 45, revealing the prevalence of different blood types within this specific age bracket. The results may offer insights into any potential correlations between age groups and blood type occurrences within the dataset.

-- 16. Find how many of patient are Universal Blood Donor and Universal Blood reciever
select distinct(select count(Blood_Type) from healthy where Blood_Type in ('O-')) as Universal_Blood_Donor,
	(select count(Blood_Type) from healthy where Blood_Type in ('AB+')) as Universal_Blood_receiver
from healthy
	-- Findings : This query extracts specific counts of individuals with particular blood types ('O-' and 'AB+') from the healthcare dataset. It compares the count of 'O-' blood type individuals (considered universal donors) against the count of 'AB+' blood type individuals (considered universal recipients). The result showcases the stark contrast in the prevalence of these two blood types within the dataset, highlighting the potential availability of universal donors compared to universal recipients.

-- 17. Create a procedure to find Universal Blood Donor to an Universal Blood Reciever, with priority to same hospital and afterwards other hospitals
DELIMITER $$
create procedure Blood_Matcher(IN Name_of_patient varchar(200))
begin
select D.Name as Donors_name,D.Age as Donors_Age, D.Blood_Type as Donors_Blood_Type, D.Hospital as Donors_Hospital,
R.Name as Receivers_name, R.Age as Receivers_Age, R.Blood_Type as Receivers_Blood_Type, R.Hospital as Receivers_Hospital
from healthy D
Inner Join healthy R on (D.Blood_Type = 'O-' and R.Blood_Type = 'AB+') and ((D.Hospital = R.Hospital) or (D.Hospital != R.Hospital))
where (R.Name regexp Name_of_patient) and (D.Age between 20 and 40);
end $$
DELIMITER ;
call Blood_Matcher('Matthew Cruz');	-- Enter the Name of patient as Argument
-- DROP PROCEDURE IF EXISTS Blood_Matcher;
	-- Findings : This stored procedure named `Blood_Matcher` is designed to identify potential donors and recipients based on specific blood types ('O-' and 'AB+') within a certain age range (20 to 40 years old). It retrieves the names, ages, blood types, and hospitals of potential donors and recipients from the Healthcare database. The condition checks for a match between the blood types and hospitals of donors and recipients, or if they are from different hospitals. Additionally, it filters recipient names matching the input provided in the procedure call using regular expression. Overall, this procedure aims to find potential matches for blood donation between donors and recipients meeting specific criteria of blood type, age, and hospital affiliation or non-affiliation.

-- 18. Provide a list of hospitals along with the count of patients admitted in the year 2024 AND 2025?
select distinct Hospital, count(*) as Total_Admitted
from healthy
where year(Date_of_Admission) in (2024,2025)
group by 1
order by Total_Admitted desc
	-- Findings : This query provides insights into billing amounts across different insurance providers in the healthcare dataset. It calculates the average, minimum, and maximum billing amounts per insurance provider. By examining these metrics, we can understand the typical billing amount range associated with each insurance provider. This information helps identify patterns in healthcare expenses linked to specific insurance companies, highlighting variations in billing practices or potential cost disparities among providers.

-- 19. Find the average, minimum and maximum billing amount for each insurance provider?
select Insurance_Provider, Round(avg(Billing_Amount),0) as Average_Amount, Round(Min(Billing_Amount),0) as Minimum_Amount,
	Round(Max(Billing_Amount),0) as Maximum_Amount
from healthy
group by 1
	-- Findings : This query provides insights into billing amounts across different insurance providers in the healthcare dataset. It calculates the average, minimum, and maximum billing amounts per insurance provider. By examining these metrics, we can understand the typical billing amount range associated with each insurance provider. This information helps identify patterns in healthcare expenses linked to specific insurance companies, highlighting variations in billing practices or potential cost disparities among providers.

-- 20. Create a new column that categorizes patients as high, medium, or low risk based on their medical condition.
select Name, Medical_Condition, Test_Results,
	case
		when Test_Results = 'Inconclusive' then 'Need More Checks / Cannot be discharge'
        when Test_Results = 'Normal' then 'Can take discharge, But need to follow Prescribed medications timely'
        when Test_Results = 'Abnormal' then 'Needs more attention and more tests'
        end as 'Status', Hospital, Doctor
from healthy
	-- Findings : This query provides a summary of patients status based on their test results for various medical conditions. It categorizes patients into distinct statuses: those requiring additional checks and unable to be discharged due to inconclusive results, individuals fit for discharge but needing strict adherence to prescribed medications for normal results, and those needing more attention and further tests for abnormal findings. It also displays associated details like the patient's name, hospital, and attending doctor, offering an overview of patient conditions, discharge possibilities, and necessary follow-up actions.
    