-- Drop the database if it exists
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'InterviewPracticeDB')
BEGIN
    ALTER DATABASE InterviewPracticeDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE InterviewPracticeDB;
END
GO

-- Create a sample database for interview practice 
CREATE DATABASE InterviewPracticeDB; 
GO 
 
USE InterviewPracticeDB; 
GO 
 -- Create tables with relationships 
CREATE TABLE Departments ( 
    DepartmentId INT PRIMARY KEY IDENTITY(1,1), 
    DepartmentName NVARCHAR(100) NOT NULL, 
    Budget DECIMAL(18,2) NOT NULL 
); 
GO 
 
CREATE TABLE Employees ( 
    EmployeeId INT PRIMARY KEY IDENTITY(1,1), 
    FirstName NVARCHAR(50) NOT NULL, 
    LastName NVARCHAR(50) NOT NULL, 
    Email NVARCHAR(100) UNIQUE, 
    HireDate DATE NOT NULL, 
    Salary DECIMAL(18,2) NOT NULL, 
    DepartmentId INT FOREIGN KEY REFERENCES Departments(DepartmentId), 
    ManagerId INT NULL FOREIGN KEY REFERENCES Employees(EmployeeId) 
); 
GO 
 
CREATE TABLE Projects ( 
    ProjectId INT PRIMARY KEY IDENTITY(1,1), 
    ProjectName NVARCHAR(100) NOT NULL, 
    StartDate DATE NOT NULL, 
    EndDate DATE NULL, 
    Budget DECIMAL(18,2) NOT NULL 
); 
GO 
 
CREATE TABLE EmployeeProjects ( 
    EmployeeId INT NOT NULL FOREIGN KEY REFERENCES Employees(EmployeeId), 
    ProjectId INT NOT NULL FOREIGN KEY REFERENCES Projects(ProjectId), 
    HoursWorked DECIMAL(8,2) NOT NULL, 
    PRIMARY KEY (EmployeeId, ProjectId) 
); 
GO 
 
CREATE TABLE AuditLog ( 
    LogId INT PRIMARY KEY IDENTITY(1,1), 
    TableName NVARCHAR(50) NOT NULL, 
    ActionType NVARCHAR(20) NOT NULL, 
    RecordId INT NOT NULL, 
    ActionDate DATETIME NOT NULL DEFAULT GETDATE(), 
    UserName NVARCHAR(100) NOT NULL DEFAULT SYSTEM_USER 
); 
GO 

-- Insert sample data 
INSERT INTO Departments (DepartmentName, Budget) 
VALUES  
    ('IT', 1000000), 
    ('HR', 500000), 
    ('Finance', 800000), 
    ('Marketing', 750000); 
GO 
INSERT INTO Employees (FirstName, LastName, Email, HireDate, Salary, DepartmentId, ManagerId) 
VALUES 
    ('John', 'Smith', 'john.smith@company.com', '2015-06-15', 85000, 1, NULL), 
    ('Sarah', 'Johnson', 'sarah.johnson@company.com', '2017-03-22', 75000, 1, 1), 
    ('Michael', 'Williams', 'michael.williams@company.com', '2018-11-10', 65000, 2, NULL), 
    ('Emily', 'Brown', 'emily.brown@company.com', '2019-05-30', 70000, 3, NULL), 
    ('David', 'Jones', 'david.jones@company.com', '2020-01-15', 60000, 1, 1), 
    ('Jessica', 'Garcia', 'jessica.garcia@company.com', '2016-09-05', 80000, 4, NULL); 
GO 

-- Update some managers 
UPDATE Employees SET ManagerId = 3 WHERE EmployeeId = 4; 
UPDATE Employees SET ManagerId = 6 WHERE EmployeeId = 5; 
GO 
INSERT INTO Projects (ProjectName, StartDate, EndDate, Budget) 
VALUES 
('Website Redesign', '2023-01-15', '2023-06-30', 50000), 
('HR System Upgrade', '2023-02-01', '2023-08-31', 75000), 
('Financial Reporting', '2023-03-01', NULL, 30000), 
('Marketing Campaign', '2023-04-01', '2023-09-30', 100000); 
GO 
INSERT INTO EmployeeProjects (EmployeeId, ProjectId, HoursWorked) 
VALUES 
(1, 1, 120), 
(2, 1, 80), 
(5, 1, 60), 
(3, 2, 100), 
(4, 3, 150), 
(6, 4, 200), 
(2, 4, 50); 
GO 

-- Create indexes 
CREATE INDEX IX_Employees_DepartmentId ON Employees(DepartmentId); 
CREATE INDEX IX_Employees_LastName ON Employees(LastName); 
CREATE INDEX IX_Projects_StartDate ON Projects(StartDate); 
GO 

-- Create views (must be first in batch) 
CREATE VIEW vw_EmployeeDetails AS 
SELECT  
e.EmployeeId, 
e.FirstName + ' ' + e.LastName AS FullName, 
e.Email, 
e.HireDate, 
e.Salary, 
d.DepartmentName, 
m.FirstName + ' ' + m.LastName AS ManagerName 
FROM Employees e 
JOIN Departments d ON e.DepartmentId = d.DepartmentId 
LEFT JOIN Employees m ON e.ManagerId = m.EmployeeId; 
GO 

-- Create stored procedures (must be first in batch) 
CREATE PROCEDURE sp_GetEmployeesByDepartment 
@DepartmentId INT 
AS 
BEGIN 
SELECT  
EmployeeId, 
FirstName + ' ' + LastName AS FullName, 
Email, 
HireDate, 
Salary 
FROM Employees 
WHERE DepartmentId = @DepartmentId 
ORDER BY LastName, FirstName; 
END; 
GO 

CREATE PROCEDURE sp_UpdateEmployeeSalary 
    @EmployeeId INT, 
    @NewSalary DECIMAL(18,2), 
    @RowsAffected INT OUTPUT 
AS 
BEGIN 
    BEGIN TRY 
        BEGIN TRANSACTION; 
         
        UPDATE Employees 
        SET Salary = @NewSalary 
        WHERE EmployeeId = @EmployeeId; 
         
        SET @RowsAffected = @@ROWCOUNT; 
         
        -- Log the change 
        INSERT INTO AuditLog (TableName, ActionType, RecordId) 
        VALUES ('Employees', 'UPDATE', @EmployeeId); 
         
        COMMIT TRANSACTION; 
    END TRY 
    BEGIN CATCH 
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION; 
             
        THROW; 
    END CATCH 
END; 
GO 

-- Create functions (must be first in batch) 
CREATE FUNCTION fn_CalculateProjectCost(@ProjectId INT) 
RETURNS DECIMAL(18,2) 
AS 
BEGIN 
    DECLARE @TotalCost DECIMAL(18,2); 
     
    SELECT @TotalCost = SUM(e.Salary * ep.HoursWorked / 2080) -- 2080 = annual work hours 
    FROM EmployeeProjects ep 
    JOIN Employees e ON ep.EmployeeId = e.EmployeeId 
    WHERE ep.ProjectId = @ProjectId; 
     
    RETURN @TotalCost; 
END; 
GO 
 
CREATE FUNCTION fn_GetDepartmentEmployees(@DepartmentName NVARCHAR(100)) 
RETURNS TABLE 
AS 
RETURN 
( 
    SELECT  
        e.EmployeeId, 
        e.FirstName + ' ' + e.LastName AS FullName, 
        e.HireDate, 
        e.Salary 
    FROM Employees e 
    JOIN Departments d ON e.DepartmentId = d.DepartmentId 
    WHERE d.DepartmentName = @DepartmentName 
); 
GO 
  
-- Create a trigger (must be first in batch) 
CREATE TRIGGER trg_EmployeeChanges 
ON Employees 
AFTER INSERT, UPDATE, DELETE 
AS 
BEGIN 
    SET NOCOUNT ON; 
     
    -- Log inserts 
    INSERT INTO AuditLog (TableName, ActionType, RecordId) 
    SELECT 'Employees', 'INSERT', EmployeeId 
    FROM inserted 
    WHERE EmployeeId NOT IN (SELECT EmployeeId FROM deleted); 
     
    -- Log updates 
    INSERT INTO AuditLog (TableName, ActionType, RecordId) 
    SELECT 'Employees', 'UPDATE', EmployeeId 
    FROM inserted 
    WHERE EmployeeId IN (SELECT EmployeeId FROM deleted); 
     
    -- Log deletes 
    INSERT INTO AuditLog (TableName, ActionType, RecordId) 
    SELECT 'Employees', 'DELETE', EmployeeId 
    FROM deleted 
    WHERE EmployeeId NOT IN (SELECT EmployeeId FROM inserted); 
END; 
GO 

-- Complex query example 
WITH DepartmentStats AS ( 
    SELECT  
        d.DepartmentId, 
        d.DepartmentName, 
        COUNT(e.EmployeeId) AS EmployeeCount, 
        AVG(e.Salary) AS AvgSalary, 
        SUM(e.Salary) AS TotalSalary 
    FROM Departments d 
    LEFT JOIN Employees e ON d.DepartmentId = e.DepartmentId 
    GROUP BY d.DepartmentId, d.DepartmentName 
) 
SELECT  
    ds.DepartmentName, 
    ds.EmployeeCount, 
    ds.AvgSalary, 
    ds.TotalSalary, 
    p.ProjectName, 
    p.Budget AS ProjectBudget, 
    COUNT(ep.EmployeeId) AS EmployeesOnProject 
FROM DepartmentStats ds 
LEFT JOIN Employees e ON ds.DepartmentId = e.DepartmentId 
LEFT JOIN EmployeeProjects ep ON e.EmployeeId = ep.EmployeeId 
LEFT JOIN Projects p ON ep.ProjectId = p.ProjectId 
GROUP BY  
    ds.DepartmentName, 
    ds.EmployeeCount, 
    ds.AvgSalary, 
    ds.TotalSalary, 
    p.ProjectName, 
    p.Budget 
ORDER BY ds.TotalSalary DESC; 
GO 

-- Declare variables for cursor use
DECLARE @EmployeeId INT;
DECLARE @FullName NVARCHAR(100);
DECLARE @Salary DECIMAL(18,2);

-- Declare the cursor
DECLARE EmployeeCursor CURSOR FOR
SELECT 
    e.EmployeeId, 
    e.FirstName + ' ' + e.LastName AS FullName, 
    e.Salary
FROM Employees e;

-- Open the cursor
OPEN EmployeeCursor;

-- Fetch the first row
FETCH NEXT FROM EmployeeCursor INTO @EmployeeId, @FullName, @Salary;

-- Loop through the cursor
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Logging salary for: ' + @FullName + ' - Salary: ' + CAST(@Salary AS NVARCHAR(50));

    -- Log into AuditLog table
    INSERT INTO AuditLog (TableName, ActionType, RecordId, UserName)
    VALUES ('Employees', 'READ-SALARY', @EmployeeId, SYSTEM_USER);

    -- Fetch the next row
    FETCH NEXT FROM EmployeeCursor INTO @EmployeeId, @FullName, @Salary;
END

-- Clean up
CLOSE EmployeeCursor;
DEALLOCATE EmployeeCursor;

-- Pivot: Show HoursWorked per Employee, each Project as a column
SELECT 
    FullName,
    ISNULL([Website Redesign], 0) AS WebsiteRedesignHours,
    ISNULL([HR System Upgrade], 0) AS HRSystemUpgradeHours,
    ISNULL([Financial Reporting], 0) AS FinancialReportingHours,
    ISNULL([Marketing Campaign], 0) AS MarketingCampaignHours
FROM
(
    SELECT 
        e.FirstName + ' ' + e.LastName AS FullName,
        p.ProjectName,
        ep.HoursWorked
    FROM EmployeeProjects ep
    JOIN Employees e ON ep.EmployeeId = e.EmployeeId
    JOIN Projects p ON ep.ProjectId = p.ProjectId
) AS SourceTable
PIVOT
(
    SUM(HoursWorked)
    FOR ProjectName IN (
        [Website Redesign],
        [HR System Upgrade],
        [Financial Reporting],
        [Marketing Campaign]
    )
) AS PivotTable
ORDER BY FullName;
GO

-- Recursive CTE: Display Employee hierarchy starting from top managers
WITH EmployeeHierarchy AS
(
    -- Anchor member: top-level managers (no ManagerId)
    SELECT 
        EmployeeId,
        FirstName + ' ' + LastName AS FullName,
        ManagerId,
        0 AS Level
    FROM Employees
    WHERE ManagerId IS NULL

    UNION ALL

    -- Recursive member: employees reporting to someone
    SELECT 
        e.EmployeeId,
        e.FirstName + ' ' + e.LastName AS FullName,
        e.ManagerId,
        eh.Level + 1
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh 
        ON e.ManagerId = eh.EmployeeId
)
SELECT 
    EmployeeId,
    FullName,
    ManagerId,
    Level
FROM EmployeeHierarchy
ORDER BY Level, FullName;
GO
