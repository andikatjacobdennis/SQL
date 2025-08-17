# SQL Server Interview Preparation (SSMS 2022)

![SQL Server](https://img.shields.io/badge/SQL_Server-2022-blue)
![License](https://img.shields.io/badge/License-MIT-green)

A comprehensive collection of SQL Server interview practice problems and solutions specifically designed for **SQL Server Management Studio 2022 (SSMS)**. This repository covers everything from basic queries to advanced T-SQL features, with a focus on real-world interview scenarios.

## Repository Contents

```
SQL-Interview-Prep/
├── .gitignore               # Standard git ignore file
├── InterviewPractice.sql    # Complete database setup with sample data
├── LICENSE                  # MIT License file
├── README.md                # This documentation
├── SQL Interview Answers.md # Detailed solutions to all questions
└── SQL Interview Questions.md # 45 categorized interview questions
```

## Features

- **200+ lines of sample database setup** with realistic tables and relationships
- **45 carefully curated interview questions** covering all SQL proficiency levels
- **Detailed solutions** with T-SQL best practices
- **SSMS 2022 optimized** scripts using modern T-SQL features
- **Real-world scenarios** including:
  - Complex joins and subqueries
  - Window functions and CTEs
  - Pivoting and hierarchical queries
  - Performance optimization techniques
  - Transaction handling and error management

## Prerequisites

- [SQL Server Management Studio 2022](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
- SQL Server 2019 or later (Developer Edition recommended)
- Basic understanding of relational databases

## Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/SQL-Interview-Prep.git
   ```

2. **Open in SSMS 2022**:
   - Launch SQL Server Management Studio
   - Open `InterviewPractice.sql`
   - Execute the entire script (F5) to create the practice database

3. **Practice questions**:
   - Work through questions in `SQL Interview Questions.md`
   - Check your solutions against `SQL Interview Answers.md`

## Sample Question Preview

```sql
-- Find the top 3 highest-paid employees in each department
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

## Learning Path

1. **Beginner**: Questions 1-10 (Basic SELECT queries, filtering, sorting)
2. **Intermediate**: Questions 11-20 (Joins, aggregations, subqueries)
3. **Advanced**: Questions 21-30 (CTEs, window functions, pivoting)
4. **Expert**: Questions 31-45 (Performance tuning, complex scenarios)

## SSMS Pro Tips

| Shortcut | Action |
|----------|--------|
| `Ctrl+T` | Display results as text |
| `Ctrl+D` | Display results as grid |
| `Ctrl+K, Ctrl+C` | Comment selection |
| `Ctrl+K, Ctrl+U` | Uncomment selection |
| `Ctrl+R` | Toggle results pane |
| `Ctrl+N` | New query window |

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
