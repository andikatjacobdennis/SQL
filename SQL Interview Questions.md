# SQL Interview Questions

## **Basic SQL Questions**
1. **Retrieve all employees from the IT department.**
2. **Find employees hired after January 1, 2019.**
3. **List all projects that are currently ongoing (no EndDate).**
4. **Count the number of employees in each department.**
5. **Find employees who earn more than $70,000.**
6. **List employees along with their department names.**
7. **Find all employees who are managers (i.e., they manage other employees).**
8. **Retrieve employees who don’t have a manager (top-level employees).**
9. **List projects sorted by budget in descending order.**
10. **Find employees whose last name starts with 'J'.**

---

## **Intermediate SQL Questions**
11. **Find the average salary per department.**
12. **List employees who work on more than one project.**
13. **Find the total hours worked per project.**
14. **List employees who earn more than the average salary in their department.**
15. **Find the department with the highest total salary expenditure.**
16. **List projects that exceed their budget (compare Budget vs. calculated cost using `fn_CalculateProjectCost`).**
17. **Find employees who have worked on all projects.**
18. **List employees who have the same manager.**
19. **Find the employee with the highest salary in each department.**
20. **List departments where the average salary is above the company-wide average.**

---

## **Advanced SQL Questions**
21. **Write a query to show the employee hierarchy (managers and their subordinates).**
22. **Use a PIVOT to display hours worked per employee per project.**
23. **Find employees who have never been assigned to a project.**
24. **Calculate the running total of salaries per department.**
25. **Find the top 3 highest-paid employees in each department.**
26. **List employees who have worked on projects outside their department.**
27. **Find projects where the total hours worked exceed the estimated budget (assuming $50/hour labor cost).**
28. **Write a query to detect salary anomalies (employees earning significantly more/less than department average).**
29. **Use a recursive CTE to find the entire reporting chain for a given employee.**
30. **Generate a report showing department budgets vs. actual salary expenditures.**

---

## **Database Design & Optimization**
31. **How would you optimize the query for finding employees by department?**
32. **When would you use a stored procedure vs. a function?**
33. **Explain how the `AuditLog` trigger works and when it fires.**
34. **What indexes would you add to improve performance?**
35. **How would you handle a scenario where an employee changes departments?**

---

## **Practical Scenarios**
36. **Write a query to give all employees in the IT department a 10% raise.**
37. **Find employees who have been with the company for more than 5 years but haven’t been promoted (salary increase < 15%).**
38. **Simulate a transaction to transfer an employee to a new department while ensuring data consistency.**
39. **Write a query to archive completed projects into a historical table.**
40. **Generate a report showing employee utilization (hours worked vs. available work hours).**

---

## **Bonus: Tricky SQL Problems**
41. **Find employees who are managers but don’t have anyone reporting to them (empty team).**
42. **List departments where the highest-paid employee earns more than twice the department average.**
43. **Find employees who have the same salary as their manager.**
44. **Calculate the salary difference between each employee and their manager.**
45. **Write a query to detect circular manager references (e.g., A manages B, B manages C, C manages A).**

---

These questions cover:

**Basic queries** (SELECT, WHERE, GROUP BY)  
**Joins & Subqueries**  
**Aggregations & Window Functions**  
**CTEs & Recursive Queries**  
**Pivoting & Dynamic SQL**  
**Performance Optimization**  
**Real-world business logic**  
