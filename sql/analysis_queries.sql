SELECT * FROM Patients LIMIT 5;

-- Question: Which patients had more than 5 visits?
-- Purpose: Identify frequent hospital users

SELECT
patients.patient_id,
patients.age,
patients.gender,
patients.age_group,
visits.visits,
visits.cost
FROM patients
JOIN visits
ON patients.patient_id = visits.patient_id
WHERE visits.visits > 5;

-- Question: Which age_group has the highest total hospital cost?
-- Purpose: Identify resource intensive age_group

SELECT
patients.age_group,
SUM(visits.cost) AS total_cost
FROM patients
JOIN visits
ON patients.patient_id = visits.patient_id
GROUP BY age_group
ORDER BY total_cost DESC;

-- Question: Which patients are classified as High burden?
-- Answer: Identify high resource patients

SELECT
patients.patient_id,
patients.age,
visits.visits,
visits.cost,
visits.burden
FROM patients
JOIN visits
ON patients.patient_id = visits.patient_id
WHERE visits.burden = "High Burden";

-- Question: Which gender has highest cost among high burden patients?
-- Purpose: Identify demographic groups driving resource use

SELECT
patients.gender,
SUM(visits.cost) AS total_cost
FROM patients
JOIN visits
ON patients.patient_id = visits.patient_id
WHERE visits.burden = 'High Burden'
GROUP BY patients.gender
ORDER BY total_cost DESC;

--Question: Which age group has the highest number of High Burden patients?
--Answer: To identify age group which requires close monitoring

SELECT
age_group,
COUNT(patients.patient_id) AS high_burden_patients
FROM patients
JOIN visits
ON patients.patient_id = visits.patient_id
WHERE visits.burden = 'High Burden'
GROUP BY patients.age_group
ORDER BY high_burden_patients DESC;

---Question: Which individual patients have the highest total cost?
---Answer: Identify patients at high risk 

SELECT
patients.patient_id,
patients.age,
patients.gender,
SUM(visits.cost) AS total_cost
FROM patients
JOIN visits
ON patients.patient_id = visits.patient_id
GROUP BY
patients.patient_id,
patients.age,
patients.gender
ORDER BY total_cost DESC
LIMIT 5;

--visits included

SELECT
patients.patient_id,
patients.age,
patients.gender,
SUM(visits.visits) AS total_visits,
SUM(visits.cost) AS total_cost
FROM patients
JOIN visits
ON patients.patient_id = visits.patient_id
GROUP BY
patients.patient_id,
patients.age,
patients.gender
ORDER BY total_cost DESC
LIMIT 5;

---Question: Which patients have high visits but relatively low cost?
---Answer: Frequent users but maybe manageable outpatient cases

SELECT
patients.patient_id,
patients.age,
patients.gender
FROM patients
JOIN visits
ON patients.patient_id = visits.patient_id
GROUP BY 
patients.patient_id,
patients.age,
patients.gender
HAVING visits.visit_frequency = 'High'
AND visits.cost_intensity = 'Low';

--- Question: Classify patients based on total treatment cost
--- Purpose: Risk stratification for resource planning

SELECT
patients.patient_id,
SUM(visits.cost) AS total_cost,
CASE
WHEN SUM(visits.cost) < 1000 THEN 'Low Cost'
WHEN SUM(visits.cost) BETWEEN 1000 AND 3000 THEN 'Medium Cost'
ELSE 'High Cost'
END AS cost_category
FROM patients
JOIN visits
ON patients.patient_id = visits.patient_id
GROUP BY patients.patient_id
ORDER BY total_cost DESC;

SELECT * FROM patients LIMIT 7;

---Question: Show all the patients who had more than 5 visits
---Answer: Identify regular patients.

SELECT 
patients.patient_id,
patients.age,
patients.gender,
visits.visits,
visits.cost
FROM patients
JOIN visits
ON patients.patient_id = visits.patient_id
WHERE visits.visits > 5;

---Question: Which age_group has the largest number?

SELECT
patients.age_group,
SUM(visits.visits) AS total_visits
FROM patients
JOIN visits
ON patients.patient_id = visits.patient_id
GROUP BY patients.age_group
ORDER BY total_visits DESC;


---Question: Which patients have total cost ABOVE the average patient cost? ( Subqueries)
---Answer: To focus on above average resource users.

SELECT
patients.patient_id,
SUM(visits.cost) AS total_cost
FROM patients
JOIN visits
ON patients.patient_id = visits.patient_id
GROUP BY patients.patient_id
HAVING SUM(visits.cost) > (
SELECT AVG(visits.cost)
FROM visits
);


---Question: Show patients whose total cost is above the average total cost per patient
---Answer: High-cost patient identification.

SELECT
patients.patient_id,
SUM(visits.cost) AS total_cost
FROM patients
JOIN visits
ON patients.patient_id = visits.patient_id
GROUP BY patients.patient_id
HAVING SUM(visits.cost) > (
SELECT AVG(total_cost)
FROM (
SELECT SUM(cost) AS total_cost
FROM visits
GROUP BY patient_id
)
);

---Question: Show all visits where cost is above average cost
---Answer: Shows visits that resulted to high resource utilization.

SELECT *
FROM visits
WHERE visits.cost > (
SELECT AVG(visits.cost)
FROM visits
);

---Question: Show all visits where cost is BELOW the average cost
---Answer: Shows the low resource utilization persons

SELECT 
visits.visit_id,
visits.patient_id,
visits.cost
FROM visits
WHERE visits.cost < (
SELECT AVG(visits.cost) FROM visits
);

---Questin: Show all visits that have the MAXIMUM cost
---Answer: Identify highest-cost visits for resource allocation analysis

SELECT *
FROM visits
WHERE visits.cost = (
SELECT MAX(visits.cost)
FROM visits
);

---Question: Patients with above average total cost per person
---Answer: Identofy high resource utilization patients.

SELECT 
patients.patient_id,
patients.age,
patients.gender,
SUM(visits.cost) AS total_cost
FROM patients
JOIN visits
ON patients.patient_id = visits.patient_id
GROUP BY patients.patient_id,
patients.age,
patients.gender
HAVING SUM(visits.cost) > (
SELECT AVG(total_cost)
FROM (
SELECT SUM(visits.cost) AS total_cost
FROM visits
GROUP BY patient_id) AS t
);