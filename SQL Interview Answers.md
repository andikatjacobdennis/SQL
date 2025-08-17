# SQL Interview Answers

## Basic SQL Questions

### 1. Retrieve all employees from the IT department.
```sql
SELECT e.*
FROM Employees e
JOIN Departments d ON e.DepartmentId = d.DepartmentId
WHERE d.DepartmentName = 'IT';
```

### 2. Find employees hired after January 1, 2019.
```sql
SELECT *
FROM Employees
WHERE HireDate > '2019-01-01';
```

### 3. List all projects that are currently ongoing (no EndDate).
```sql
SELECT *
FROM Projects
WHERE EndDate IS NULL;
```

### 4. Count the number of employees in each department.
```sql
SELECT d.DepartmentName, COUNT(e.EmployeeId) AS EmployeeCount
FROM Departments d
LEFT JOIN Employees e ON d.DepartmentId = e.DepartmentId
GROUP BY d.DepartmentName;
```

### 5. Find employees who earn more than $70,000.
```sql
SELECT *
FROM Employees
WHERE Salary > 70000;
```

### 6. List employees along with their department names.
```sql
SELECT e.*, d.DepartmentName
FROM Employees e
JOIN Departments d ON e.DepartmentId = d.DepartmentId;
```

### 7. Find all employees who are managers (i.e., they manage other employees).
```sql
SELECT DISTINCT m.*
FROM Employees e
JOIN Employees m ON e.ManagerId = m.EmployeeId;
```

### 8. Retrieve employees who don't have a manager (top-level employees).
```sql
SELECT *
FROM Employees
WHERE ManagerId IS NULL;
```

### 9. List projects sorted by budget in descending order.
```sql
SELECT *
FROM Projects
ORDER BY Budget DESC;
```

### 10. Find employees whose last name starts with 'J'.
```sql
SELECT *
FROM Employees
WHERE LastName LIKE 'J%';
```

## Intermediate SQL Questions

### 11. Find the average salary per department.
```sql
SELECT d.DepartmentName, AVG(e.Salary) AS AvgSalary
FROM Departments d
JOIN Employees e ON d.DepartmentId = e.DepartmentId
GROUP BY d.DepartmentName;
```

### 12. List employees who work on more than one project.
```sql
SELECT e.EmployeeId, e.FirstName, e.LastName, COUNT(ep.ProjectId) AS ProjectCount
FROM Employees e
JOIN EmployeeProjects ep ON e.EmployeeId = ep.EmployeeId
GROUP BY e.EmployeeId, e.FirstName, e.LastName
HAVING COUNT(ep.ProjectId) > 1;
```

### 13. Find the total hours worked per project.
```sql
SELECT p.ProjectName, SUM(ep.HoursWorked) AS TotalHours
FROM Projects p
JOIN EmployeeProjects ep ON p.ProjectId = ep.ProjectId
GROUP BY p.ProjectName;
```

### 14. List employees who earn more than the average salary in their department.
```sql
WITH DeptAvg AS (
    SELECT DepartmentId, AVG(Salary) AS AvgSalary
    FROM Employees
    GROUP BY DepartmentId
)
SELECT e.*
FROM Employees e
JOIN DeptAvg da ON e.DepartmentId = da.DepartmentId
WHERE e.Salary > da.AvgSalary;
```

### 15. Find the department with the highest total salary expenditure.
```sql
SELECT TOP 1 d.DepartmentName, SUM(e.Salary) AS TotalSalary
FROM Departments d
JOIN Employees e ON d.DepartmentId = e.DepartmentId
GROUP BY d.DepartmentName
ORDER BY TotalSalary DESC;
```

### 16. List projects that exceed their budget.
```sql
SELECT p.ProjectId, p.ProjectName, p.Budget, dbo.fn_CalculateProjectCost(p.ProjectId) AS ActualCost
FROM Projects p
WHERE dbo.fn_CalculateProjectCost(p.ProjectId) > p.Budget;
```

### 17. Find employees who have worked on all projects.
```sql
SELECT e.EmployeeId, e.FirstName, e.LastName
FROM Employees e
WHERE NOT EXISTS (
    SELECT p.ProjectId 
    FROM Projects p
    WHERE NOT EXISTS (
        SELECT 1 
        FROM EmployeeProjects ep 
        WHERE ep.EmployeeId = e.EmployeeId AND ep.ProjectId = p.ProjectId
    )
);
```

### 18. List employees who have the same manager.
```sql
SELECT m.FirstName + ' ' + m.LastName AS ManagerName, 
       STRING_AGG(e.FirstName + ' ' + e.LastName, ', ') AS Employees
FROM Employees e
JOIN Employees m ON e.ManagerId = m.EmployeeId
GROUP BY m.FirstName, m.LastName, m.EmployeeId
HAVING COUNT(*) > 1;
```

### 19. Find the employee with the highest salary in each department.
```sql
WITH RankedEmployees AS (
    SELECT e.*,
           RANK() OVER (PARTITION BY e.DepartmentId ORDER BY e.Salary DESC) AS Rank
    FROM Employees e
)
SELECT re.EmployeeId, re.FirstName, re.LastName, re.Salary, d.DepartmentName
FROM RankedEmployees re
JOIN Departments d ON re.DepartmentId = d.DepartmentId
WHERE re.Rank = 1;
```

### 20. List departments where the average salary is above the company-wide average.
```sql
WITH DeptStats AS (
    SELECT d.DepartmentId, d.DepartmentName, AVG(e.Salary) AS DeptAvgSalary
    FROM Departments d
    JOIN Employees e ON d.DepartmentId = e.DepartmentId
    GROUP BY d.DepartmentId, d.DepartmentName
),
CompanyAvg AS (
    SELECT AVG(Salary) AS CompanyAvgSalary FROM Employees
)
SELECT ds.*
FROM DeptStats ds
CROSS JOIN CompanyAvg ca
WHERE ds.DeptAvgSalary > ca.CompanyAvgSalary;
```

## Advanced SQL Questions

### 21. Write a query to show the employee hierarchy.
```sql
WITH EmployeeHierarchy AS (
    -- Base case: top-level employees
    SELECT EmployeeId, FirstName, LastName, ManagerId, 0 AS Level
    FROM Employees
    WHERE ManagerId IS NULL
    
    UNION ALL
    
    -- Recursive case: employees with managers
    SELECT e.EmployeeId, e.FirstName, e.LastName, e.ManagerId, eh.Level + 1
    FROM Employees e
    JOIN EmployeeHierarchy eh ON e.ManagerId = eh.EmployeeId
)
SELECT 
    EmployeeId, 
    FirstName + ' ' + LastName AS EmployeeName,
    REPLICATE('    ', Level) + FirstName + ' ' + LastName AS HierarchyDisplay,
    Level
FROM EmployeeHierarchy
ORDER BY Level, LastName, FirstName;
```

### 22. Use a PIVOT to display hours worked per employee per project.
```sql
SELECT *
FROM (
    SELECT 
        e.FirstName + ' ' + e.LastName AS EmployeeName,
        p.ProjectName,
        ep.HoursWorked
    FROM EmployeeProjects ep
    JOIN Employees e ON ep.EmployeeId = e.EmployeeId
    JOIN Projects p ON ep.ProjectId = p.ProjectId
) AS SourceTable
PIVOT (
    SUM(HoursWorked)
    FOR ProjectName IN (
        [Website Redesign],
        [HR System Upgrade],
        [Financial Reporting],
        [Marketing Campaign]
    )
) AS PivotTable;
```

### 23. Find employees who have never been assigned to a project.
```sql
SELECT e.*
FROM Employees e
LEFT JOIN EmployeeProjects ep ON e.EmployeeId = ep.EmployeeId
WHERE ep.EmployeeId IS NULL;
```

### 24. Calculate the running total of salaries per department.
```sql
SELECT 
    e.EmployeeId,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    d.DepartmentName,
    e.Salary,
    SUM(e.Salary) OVER (PARTITION BY e.DepartmentId ORDER BY e.Salary DESC) AS RunningTotal
FROM Employees e
JOIN Departments d ON e.DepartmentId = d.DepartmentId;
```

### 25. Find the top 3 highest-paid employees in each department.
```sql
WITH RankedEmployees AS (
    SELECT e.*,
           DENSE_RANK() OVER (PARTITION BY DepartmentId ORDER BY Salary DESC) AS SalaryRank
    FROM Employees e
)
SELECT re.EmployeeId, re.FirstName, re.LastName, re.Salary, d.DepartmentName
FROM RankedEmployees re
JOIN Departments d ON re.DepartmentId = d.DepartmentId
WHERE re.SalaryRank <= 3
ORDER BY d.DepartmentName, re.SalaryRank;
```

### 26. List employees who have worked on projects outside their department.
```sql
SELECT DISTINCT e.EmployeeId, e.FirstName, e.LastName, d.DepartmentName AS EmployeeDept, 
       pd.DepartmentName AS ProjectDept
FROM Employees e
JOIN EmployeeProjects ep ON e.EmployeeId = ep.EmployeeId
JOIN Projects p ON ep.ProjectId = p.ProjectId
JOIN Departments d ON e.DepartmentId = d.DepartmentId
JOIN Departments pd ON p.DepartmentId = pd.DepartmentId
WHERE e.DepartmentId <> p.DepartmentId;
```

### 27. Find projects where total hours worked exceed estimated budget.
```sql
SELECT p.ProjectId, p.ProjectName, p.Budget, 
       SUM(ep.HoursWorked * 50) AS EstimatedCost,
       CASE WHEN SUM(ep.HoursWorked * 50) > p.Budget THEN 'Over Budget' ELSE 'Within Budget' END AS Status
FROM Projects p
JOIN EmployeeProjects ep ON p.ProjectId = ep.ProjectId
GROUP BY p.ProjectId, p.ProjectName, p.Budget
HAVING SUM(ep.HoursWorked * 50) > p.Budget;
```

### 28. Detect salary anomalies (employees earning significantly more/less than department average).
```sql
WITH DeptStats AS (
    SELECT 
        DepartmentId,
        AVG(Salary) AS AvgSalary,
        STDEV(Salary) AS StdDevSalary
    FROM Employees
    GROUP BY DepartmentId
)
SELECT 
    e.EmployeeId,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    d.DepartmentName,
    e.Salary,
    ds.AvgSalary AS DepartmentAverage,
    CASE 
        WHEN e.Salary > ds.AvgSalary + (2 * ds.StdDevSalary) THEN 'High Outlier'
        WHEN e.Salary < ds.AvgSalary - (2 * ds.StdDevSalary) THEN 'Low Outlier'
        ELSE 'Normal'
    END AS SalaryStatus
FROM Employees e
JOIN Departments d ON e.DepartmentId = d.DepartmentId
JOIN DeptStats ds ON e.DepartmentId = ds.DepartmentId
WHERE e.Salary > ds.AvgSalary + (2 * ds.StdDevSalary) OR 
      e.Salary < ds.AvgSalary - (2 * ds.StdDevSalary);
```

### 29. Use a recursive CTE to find the entire reporting chain for a given employee.
```sql
DECLARE @EmployeeId INT = 5; -- Example employee ID

WITH ReportingChain AS (
    -- Base case: the employee
    SELECT EmployeeId, FirstName, LastName, ManagerId, 0 AS Level
    FROM Employees
    WHERE EmployeeId = @EmployeeId
    
    UNION ALL
    
    -- Recursive case: move up the chain
    SELECT e.EmployeeId, e.FirstName, e.LastName, e.ManagerId, rc.Level + 1
    FROM Employees e
    JOIN ReportingChain rc ON e.EmployeeId = rc.ManagerId
)
SELECT 
    EmployeeId, 
    FirstName + ' ' + LastName AS EmployeeName,
    ManagerId,
    Level,
    CASE WHEN Level = 0 THEN 'Employee' ELSE 'Manager ' + CAST(Level AS VARCHAR) END AS Role
FROM ReportingChain
ORDER BY Level DESC;
```

### 30. Generate a report showing department budgets vs. actual salary expenditures.
```sql
SELECT 
    d.DepartmentId,
    d.DepartmentName,
    d.Budget AS DepartmentBudget,
    SUM(e.Salary) AS TotalSalaries,
    d.Budget - SUM(e.Salary) AS BudgetDifference,
    CASE 
        WHEN SUM(e.Salary) > d.Budget THEN 'Over Budget'
        ELSE 'Within Budget'
    END AS BudgetStatus
FROM Departments d
JOIN Employees e ON d.DepartmentId = e.DepartmentId
GROUP BY d.DepartmentId, d.DepartmentName, d.Budget
ORDER BY BudgetDifference;
```

## Database Design & Optimization

### 31. How would you optimize the query for finding employees by department?
**Answer:** 
1. Ensure there's an index on the DepartmentId column in the Employees table
2. Consider a covering index that includes frequently accessed columns
3. For large datasets, consider partitioning the Employees table by DepartmentId
4. Use query hints if necessary for specific optimization cases

### 32. When would you use a stored procedure vs. a function?
**Answer:**
- **Stored Procedures** are better when:
  - You need to perform DML operations (INSERT, UPDATE, DELETE)
  - You need to return multiple result sets
  - You need to implement complex business logic with transactions
  - You need to execute dynamic SQL
  - You don't need the result in a query (can be called with EXEC)

- **Functions** are better when:
  - You need to return a single value or table that can be used in a SELECT statement
  - You need to encapsulate calculation logic that will be reused in queries
  - You need deterministic results (some functions must be deterministic)
  - You want to use the result in JOIN, WHERE, or other query clauses

### 33. Explain how the AuditLog trigger works and when it fires.
**Answer:**
The `trg_EmployeeChanges` trigger is an AFTER trigger that fires when INSERT, UPDATE, or DELETE operations occur on the Employees table. It:
1. Checks the inserted and deleted tables to determine the operation type
2. For INSERTs, logs new records with 'INSERT' action
3. For UPDATEs, logs changed records with 'UPDATE' action
4. For DELETEs, logs removed records with 'DELETE' action
5. Records the table name, action type, record ID, current date/time, and user who made the change

### 34. What indexes would you add to improve performance?
**Answer:**
1. **Composite index** on (DepartmentId, Salary) for department salary queries
2. **Covering index** on (ManagerId, EmployeeId) for hierarchy queries
3. **Index** on HireDate for date-based queries
4. **Filtered index** on Salary WHERE Salary > 100000 for high-salary queries
5. **Full-text index** on FirstName, LastName for name searches
6. **Index** on ProjectId in EmployeeProjects for project-related queries

### 35. How would you handle a scenario where an employee changes departments?
**Answer:**
1. Use a transaction to ensure data consistency
2. Update the DepartmentId in the Employees table
3. Check if the employee should be removed from projects in the old department
4. Update any department-specific permissions or attributes
5. Log the change in the AuditLog
6. Consider adding a history table to track department changes over time

## Practical Scenarios

### 36. Give all employees in the IT department a 10% raise.
```sql
BEGIN TRANSACTION;

UPDATE Employees
SET Salary = Salary * 1.10
WHERE DepartmentId = (SELECT DepartmentId FROM Departments WHERE DepartmentName = 'IT');

-- Verify the changes
SELECT e.EmployeeId, e.FirstName, e.LastName, e.Salary
FROM Employees e
JOIN Departments d ON e.DepartmentId = d.DepartmentId
WHERE d.DepartmentName = 'IT';

COMMIT TRANSACTION;
```

### 37. Find employees with >5 years tenure but <15% salary increase.
```sql
WITH EmployeeHistory AS (
    SELECT 
        e.EmployeeId,
        e.FirstName,
        e.LastName,
        e.HireDate,
        e.Salary AS CurrentSalary,
        DATEDIFF(YEAR, e.HireDate, GETDATE()) AS YearsOfService,
        FIRST_VALUE(e.Salary) OVER (PARTITION BY e.EmployeeId ORDER BY al.ActionDate) AS StartingSalary
    FROM Employees e
    JOIN AuditLog al ON e.EmployeeId = al.RecordId AND al.TableName = 'Employees' AND al.ActionType = 'INSERT'
)
SELECT 
    EmployeeId,
    FirstName,
    LastName,
    YearsOfService,
    StartingSalary,
    CurrentSalary,
    (CurrentSalary - StartingSalary) / StartingSalary * 100 AS SalaryIncreasePercentage
FROM EmployeeHistory
WHERE YearsOfService > 5 AND 
      ((CurrentSalary - StartingSalary) / StartingSalary * 100) < 15;
```

### 38. Simulate a transaction to transfer an employee to a new department.
```sql
BEGIN TRY
    BEGIN TRANSACTION;
    
    DECLARE @EmployeeId INT = 2; -- Example employee
    DECLARE @NewDeptId INT = 3; -- Example new department (Finance)
    DECLARE @OldDeptId INT;
    
    -- Get current department
    SELECT @OldDeptId = DepartmentId 
    FROM Employees 
    WHERE EmployeeId = @EmployeeId;
    
    -- Update department
    UPDATE Employees
    SET DepartmentId = @NewDeptId
    WHERE EmployeeId = @EmployeeId;
    
    -- Remove from projects in old department
    DELETE ep
    FROM EmployeeProjects ep
    JOIN Projects p ON ep.ProjectId = p.ProjectId
    WHERE ep.EmployeeId = @EmployeeId AND p.DepartmentId = @OldDeptId;
    
    -- Log the change
    INSERT INTO AuditLog (TableName, ActionType, RecordId, UserName)
    VALUES ('Employees', 'TRANSFER', @EmployeeId, SYSTEM_USER);
    
    COMMIT TRANSACTION;
    
    SELECT 'Transfer completed successfully' AS Result;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    SELECT 'Transfer failed: ' + ERROR_MESSAGE() AS Result;
END CATCH;
```

### 39. Archive completed projects into a historical table.
```sql
-- First create the archive table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProjectsArchive')
BEGIN
    CREATE TABLE ProjectsArchive (
        ProjectId INT PRIMARY KEY,
        ProjectName NVARCHAR(100) NOT NULL,
        StartDate DATE NOT NULL,
        EndDate DATE NULL,
        Budget DECIMAL(18,2) NOT NULL,
        ArchivedDate DATETIME DEFAULT GETDATE()
    );
END

-- Archive completed projects
BEGIN TRANSACTION;

INSERT INTO ProjectsArchive (ProjectId, ProjectName, StartDate, EndDate, Budget)
SELECT ProjectId, ProjectName, StartDate, EndDate, Budget
FROM Projects
WHERE EndDate IS NOT NULL AND EndDate < GETDATE();

DELETE FROM EmployeeProjects
WHERE ProjectId IN (SELECT ProjectId FROM ProjectsArchive);

DELETE FROM Projects
WHERE ProjectId IN (SELECT ProjectId FROM ProjectsArchive);

COMMIT TRANSACTION;
```

### 40. Generate a report showing employee utilization.
```sql
SELECT 
    e.EmployeeId,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    d.DepartmentName,
    SUM(ep.HoursWorked) AS TotalHoursWorked,
    2080 AS AnnualAvailableHours, -- Standard work hours per year
    (SUM(ep.HoursWorked) / 2080.0) * 100 AS UtilizationPercentage
FROM Employees e
LEFT JOIN EmployeeProjects ep ON e.EmployeeId = ep.EmployeeId
JOIN Departments d ON e.DepartmentId = d.DepartmentId
GROUP BY e.EmployeeId, e.FirstName, e.LastName, d.DepartmentName
ORDER BY UtilizationPercentage DESC;
```

## Bonus: Tricky SQL Problems

### 41. Find managers with no direct reports.
```sql
SELECT m.*
FROM Employees m
LEFT JOIN Employees e ON m.EmployeeId = e.ManagerId
WHERE m.ManagerId IS NULL AND e.EmployeeId IS NULL;
```

### 42. List departments where highest-paid employee earns >2x department average.
```sql
WITH DeptStats AS (
    SELECT 
        d.DepartmentId,
        d.DepartmentName,
        AVG(e.Salary) AS AvgSalary,
        MAX(e.Salary) AS MaxSalary
    FROM Departments d
    JOIN Employees e ON d.DepartmentId = e.DepartmentId
    GROUP BY d.DepartmentId, d.DepartmentName
)
SELECT 
    DepartmentId,
    DepartmentName,
    AvgSalary,
    MaxSalary,
    MaxSalary / AvgSalary AS Ratio
FROM DeptStats
WHERE MaxSalary > 2 * AvgSalary;
```

### 43. Find employees with the same salary as their manager.
```sql
SELECT e.EmployeeId, e.FirstName, e.LastName, e.Salary,
       m.EmployeeId AS ManagerId, 
       m.FirstName + ' ' + m.LastName AS ManagerName,
       m.Salary AS ManagerSalary
FROM Employees e
JOIN Employees m ON e.ManagerId = m.EmployeeId
WHERE e.Salary = m.Salary;
```

### 44. Calculate salary difference between employees and their managers.
```sql
SELECT 
    e.EmployeeId,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    e.Salary,
    m.EmployeeId AS ManagerId,
    m.FirstName + ' ' + m.LastName AS ManagerName,
    m.Salary AS ManagerSalary,
    e.Salary - m.Salary AS SalaryDifference
FROM Employees e
JOIN Employees m ON e.ManagerId = m.EmployeeId
ORDER BY SalaryDifference DESC;
```

### 45. Detect circular manager references.
```sql
WITH EmployeePaths AS (
    -- Start with all employees
    SELECT 
        EmployeeId AS StartId,
        EmployeeId,
        ManagerId,
        1 AS Depth,
        CAST(EmployeeId AS VARCHAR(MAX)) AS Path
    FROM Employees
    
    UNION ALL
    
    -- Follow manager relationships
    SELECT 
        ep.StartId,
        e.EmployeeId,
        e.ManagerId,
        ep.Depth + 1,
        ep.Path + '->' + CAST(e.EmployeeId AS VARCHAR(MAX))
    FROM EmployeePaths ep
    JOIN Employees e ON ep.ManagerId = e.EmployeeId
    WHERE ep.Depth < 10 -- Prevent infinite recursion
)
SELECT DISTINCT 
    e1.FirstName + ' ' + e1.LastName AS EmployeeInLoop,
    ep.Path AS CircularPath
FROM EmployeePaths ep
JOIN Employees e1 ON ep.StartId = e1.EmployeeId
WHERE ep.StartId = ep.ManagerId OR ep.Path LIKE '%' + CAST(ep.StartId AS VARCHAR(10)) + '%->%' + CAST(ep.StartId AS VARCHAR(10)) + '%';
```
