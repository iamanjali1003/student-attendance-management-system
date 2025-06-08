# Guide

## Table of Contents

1. [System Overview](#system-overview)
2. [Installation & Setup](#installation--setup)
3. [Database Structure](#database-structure)
4. [Basic Operations](#basic-operations)
5. [Advanced Features](#advanced-features)
6. [Stored Procedures](#stored-procedures)
7. [Triggers](#triggers)
8. [Sample Queries](#sample-queries)
9. [Troubleshooting](#troubleshooting)

## System Overview

The Student Attendance Management System is a comprehensive database solution designed for educational institutions to track and manage student attendance across multiple courses, departments, and faculty members.

### Key Features

- ✅ Multi-department support
- ✅ Faculty-course assignments
- ✅ Student enrollment management
- ✅ Automated attendance tracking
- ✅ Comprehensive reporting
- ✅ Audit trail with triggers
- ✅ Stored procedures for complex operations
- ✅ Data integrity with constraints

## Installation & Setup

### Prerequisites

- MySQL Server 8.0 or higher
- MySQL Workbench (recommended) or command line access
- Basic knowledge of SQL

### Step 1: Database Setup

1. Open MySQL Workbench or command line
2. Run the master setup script:

```sql
SOURCE setup.sql;
```

This will:

- Create the database `student_attendance_db`
- Create all tables with proper constraints
- Set up triggers for audit logging
- Create stored procedures
- Insert sample data for testing

### Step 2: Verify Installation

After running the setup script, verify the installation:

```sql
USE student_attendance_db;

-- Check tables
SHOW TABLES;

-- Check sample data
SELECT COUNT(*) as Students FROM Students;
SELECT COUNT(*) as Courses FROM Courses;
SELECT COUNT(*) as Attendance_Records FROM Attendance;
```

## Database Structure

### Core Tables

#### 1. Departments

Stores department information

```sql
SELECT * FROM Departments;
```

#### 2. Faculty

Faculty member details linked to departments

```sql
SELECT f.name, d.department_name
FROM Faculty f
JOIN Departments d ON f.department_id = d.department_id;
```

#### 3. Students

Student information with department association

```sql
SELECT s.name, s.roll_number, d.department_name
FROM Students s
JOIN Departments d ON s.department_id = d.department_id;
```

#### 4. Courses

Course details with faculty assignments

```sql
SELECT c.course_name, c.course_code, f.name as faculty
FROM Courses c
JOIN Faculty f ON c.faculty_id = f.faculty_id;
```

#### 5. Course_Enrollments

Student-course enrollment tracking

```sql
SELECT s.name, c.course_name, ce.enrollment_date
FROM Course_Enrollments ce
JOIN Students s ON ce.student_id = s.student_id
JOIN Courses c ON ce.course_id = c.course_id;
```

#### 6. Attendance

Daily attendance records

```sql
SELECT s.name, c.course_name, a.date, a.status
FROM Attendance a
JOIN Students s ON a.student_id = s.student_id
JOIN Courses c ON a.course_id = c.course_id
ORDER BY a.date DESC;
```

## Basic Operations

### Adding New Records

#### Add a New Department

```sql
INSERT INTO Departments (department_name)
VALUES ('Data Science');
```

#### Add a New Faculty Member

```sql
INSERT INTO Faculty (name, department_id, email, phone)
VALUES ('Dr. John Smith', 1, 'john.smith@college.edu', '9876543216');
```

#### Add a New Student

```sql
INSERT INTO Students (name, department_id, email, roll_number, phone)
VALUES ('Alice Johnson', 1, 'alice.johnson@student.edu', 'CS2024002', '8765432112');
```

#### Add a New Course

```sql
INSERT INTO Courses (course_name, course_code, faculty_id, department_id, credits)
VALUES ('Artificial Intelligence', 'BCS801', 1, 1, 4);
```

#### Enroll Student in Course

```sql
INSERT INTO Course_Enrollments (student_id, course_id, enrollment_date)
VALUES (1, 1, CURRENT_DATE);
```

#### Mark Attendance

```sql
INSERT INTO Attendance (student_id, course_id, date, status, marked_by)
VALUES (1, 1, CURRENT_DATE, 'Present', 1);
```

### Updating Records

#### Update Student Information

```sql
UPDATE Students
SET phone = '9999999999', email = 'new.email@student.edu'
WHERE student_id = 1;
```

#### Update Attendance Status

```sql
UPDATE Attendance
SET status = 'Present'
WHERE student_id = 1 AND course_id = 1 AND date = '2024-01-29';
```

### Viewing Data

#### Student Attendance Summary

```sql
SELECT
    s.name AS Student,
    c.course_name AS Course,
    COUNT(a.attendance_id) AS Total_Classes,
    SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) AS Attended,
    ROUND(
        (SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) * 100.0) /
        COUNT(a.attendance_id), 2
    ) AS Attendance_Percentage
FROM Students s
JOIN Attendance a ON s.student_id = a.student_id
JOIN Courses c ON a.course_id = c.course_id
GROUP BY s.student_id, c.course_id
ORDER BY Attendance_Percentage DESC;
```

## Advanced Features

### 1. Attendance Analytics

#### Department-wise Attendance Report

```sql
SELECT
    d.department_name,
    COUNT(DISTINCT s.student_id) as Total_Students,
    AVG(
        CASE WHEN a.status IN ('Present', 'Late') THEN 100.0 ELSE 0.0 END
    ) as Avg_Attendance_Rate
FROM Departments d
LEFT JOIN Students s ON d.department_id = s.department_id
LEFT JOIN Attendance a ON s.student_id = a.student_id
GROUP BY d.department_id;
```

#### Monthly Attendance Trends

```sql
SELECT
    YEAR(a.date) as Year,
    MONTH(a.date) as Month,
    COUNT(a.attendance_id) as Total_Records,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) as Present_Count,
    ROUND(
        (SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) * 100.0) /
        COUNT(a.attendance_id), 2
    ) as Monthly_Attendance_Rate
FROM Attendance a
GROUP BY YEAR(a.date), MONTH(a.date)
ORDER BY Year DESC, Month DESC;
```

### 2. Low Attendance Alerts

```sql
SELECT
    s.name as Student,
    c.course_name as Course,
    ROUND(
        (SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) * 100.0) /
        COUNT(a.attendance_id), 2
    ) as Attendance_Percentage
FROM Students s
JOIN Attendance a ON s.student_id = a.student_id
JOIN Courses c ON a.course_id = c.course_id
GROUP BY s.student_id, c.course_id
HAVING Attendance_Percentage < 75
ORDER BY Attendance_Percentage ASC;
```

## Stored Procedures

### 1. Calculate Attendance Percentage

```sql
CALL CalculateAttendancePercentage(1, 1, @percentage, @total, @present);
SELECT @percentage as Attendance_Percentage, @total as Total_Classes, @present as Present_Classes;
```

### 2. Get Student Attendance Report

```sql
CALL GetStudentAttendanceReport(1);
```

### 3. Auto-mark Absent Students

```sql
CALL AutoMarkAbsent('2024-01-30', 1);
```

### 4. Get Course Attendance Summary

```sql
CALL GetCourseAttendanceSummary(1, '2024-01-30');
```

### 5. Bulk Mark Attendance

```sql
CALL BulkMarkAttendance(1, '2024-01-30', '1,2,3,4', 'Present', 1);
```

### 6. Get Low Attendance Students

```sql
CALL GetLowAttendanceStudents(75.00);
```

## Triggers

The system includes several triggers for audit logging and data validation:

### 1. Attendance Logging Triggers

- **attendance_insert_log**: Logs new attendance records
- **attendance_update_log**: Logs attendance modifications
- **attendance_delete_log**: Logs attendance deletions

### 2. Validation Triggers

- **validate_attendance_date**: Prevents future date attendance
- **update_attendance_timestamp**: Auto-updates modification time

### 3. Viewing Trigger Logs

```sql
SELECT * FROM Attendance_Log
ORDER BY changed_at DESC
LIMIT 10;
```

## Sample Queries

### Daily Attendance Report

```sql
SELECT
    DATE(a.date) as Date,
    c.course_name as Course,
    COUNT(a.attendance_id) as Total_Students,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) as Present,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) as Absent,
    SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END) as Late
FROM Attendance a
JOIN Courses c ON a.course_id = c.course_id
WHERE a.date = CURRENT_DATE
GROUP BY a.date, c.course_id;
```

### Faculty Workload Report

```sql
SELECT
    f.name as Faculty,
    COUNT(DISTINCT c.course_id) as Courses_Teaching,
    COUNT(DISTINCT s.student_id) as Total_Students,
    COUNT(a.attendance_id) as Attendance_Records_Managed
FROM Faculty f
LEFT JOIN Courses c ON f.faculty_id = c.faculty_id
LEFT JOIN Course_Enrollments ce ON c.course_id = ce.course_id
LEFT JOIN Students s ON ce.student_id = s.student_id
LEFT JOIN Attendance a ON c.course_id = a.course_id
GROUP BY f.faculty_id;
```

### Student Performance Dashboard

```sql
SELECT
    s.student_id,
    s.name as Student_Name,
    s.roll_number,
    COUNT(DISTINCT ce.course_id) as Enrolled_Courses,
    COUNT(a.attendance_id) as Total_Classes,
    ROUND(AVG(
        CASE WHEN a.status IN ('Present', 'Late') THEN 100.0 ELSE 0.0 END
    ), 2) as Overall_Attendance_Percentage
FROM Students s
LEFT JOIN Course_Enrollments ce ON s.student_id = ce.student_id
LEFT JOIN Attendance a ON s.student_id = a.student_id
GROUP BY s.student_id
ORDER BY Overall_Attendance_Percentage DESC;
```

## Troubleshooting

### Common Issues

#### 1. Foreign Key Constraint Errors

**Problem**: Cannot insert/update due to foreign key constraints
**Solution**: Ensure referenced records exist before insertion

```sql
-- Check if department exists before adding faculty
SELECT * FROM Departments WHERE department_id = 1;
```

#### 2. Duplicate Entry Errors

**Problem**: Trying to insert duplicate unique values
**Solution**: Check existing records first

```sql
-- Check if email already exists
SELECT * FROM Students WHERE email = 'test@student.edu';
```

#### 3. Trigger Not Working

**Problem**: Triggers not logging changes
**Solution**: Check trigger status

```sql
SHOW TRIGGERS LIKE 'attendance%';
```

#### 4. Procedure Execution Errors

**Problem**: Stored procedure fails
**Solution**: Check procedure syntax and parameters

```sql
SHOW PROCEDURE STATUS WHERE Name = 'CalculateAttendancePercentage';
```

### Performance Optimization

#### 1. Use Indexes

The system includes indexes on frequently queried columns:

```sql
SHOW INDEX FROM Attendance;
```

#### 2. Optimize Queries

Use EXPLAIN to analyze query performance:

```sql
EXPLAIN SELECT * FROM Attendance WHERE date = '2024-01-30';
```

### Data Backup

Regular backup is recommended:

```sql
-- Create backup
mysqldump -u username -p student_attendance_db > backup.sql

-- Restore backup
mysql -u username -p student_attendance_db < backup.sql
```

### Support

For additional support:

1. Check the ER diagram documentation
2. Review sample queries in the queries/ directory
3. Test with the provided sample data
4. Verify all constraints and relationships are properly set up

## Best Practices

1. **Data Entry**: Always validate data before insertion
2. **Attendance**: Mark attendance daily to maintain accuracy
3. **Backup**: Regular database backups
4. **Monitoring**: Check attendance logs regularly
5. **Performance**: Use appropriate indexes for large datasets
6. **Security**: Implement proper user access controls
7. **Maintenance**: Regular cleanup of old log entries
