<div align="center">
<h1>Student Attendance Management System</h1>
<h4>DBMS Lab (BCS403) Mini Project</h4>
</div>

# Overview

A comprehensive database management system for tracking student attendance across multiple courses, departments, and faculty members. Built for **BCS403 – DBMS Lab** as a mini project.

This system provides a complete solution for educational institutions to manage student attendance efficiently. It includes proper database design with normalization up to 3NF, comprehensive CRUD operations, triggers for audit logging, and stored procedures for complex operations.

## Features

- **🏢 Multi-Department Support**: Manage multiple departments with faculty and students
- **👨‍🏫 Faculty Management**: Assign courses to faculty members
- **👨‍🎓 Student Enrollment**: Track student enrollments across courses
- **📅 Attendance Tracking**: Daily attendance with Present/Absent/Late status
- **📊 Comprehensive Reporting**: Detailed analytics and reports
- **🔍 Audit Trail**: Complete logging of all attendance changes
- **⚡ Automated Procedures**: Bulk operations and percentage calculations
- **🛡️ Data Integrity**: Foreign key constraints and validation triggers
- **📈 Performance Optimized**: Proper indexing for fast queries

## Quick Start

#### Prerequisites

- MySQL Server 8.0+
- MySQL Workbench (recommended)

#### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd student-attendance-management-system
   ```

2. **Run the setup script**

   ```sql
   SOURCE setup.sql;
   ```

3. **Verify installation**
   ```sql
   USE student_attendance_db;
   SHOW TABLES;
   ```

## Database Schema

#### Core Tables

- **Departments**: Department information
- **Faculty**: Faculty members linked to departments
- **Students**: Student details with department association
- **Courses**: Course information with faculty assignments
- **Course_Enrollments**: Student-course enrollment tracking
- **Attendance**: Daily attendance records
- **Attendance_Log**: Audit trail for all changes

#### Key Relationships

- Department → Faculty (1:M)
- Department → Students (1:M)
- Faculty → Courses (1:M)
- Students ↔ Courses (M:M via Enrollments)
- Students → Attendance (1:M)
- Courses → Attendance (1:M)

## Key Components

#### 1. **CRUD Operations**

Complete Create, Read, Update, Delete operations for all entities with examples in `queries/crud_operations.sql`.

#### 2. **Triggers**

- **Audit Logging**: Automatic logging of attendance changes
- **Data Validation**: Prevent invalid data entry
- **Timestamp Management**: Auto-update modification times

#### 3. **Stored Procedures**

- `CalculateAttendancePercentage()`: Calculate student attendance percentage
- `GetStudentAttendanceReport()`: Comprehensive student reports
- `AutoMarkAbsent()`: Auto-mark unmarked students as absent
- `BulkMarkAttendance()`: Mark attendance for multiple students
- `GetLowAttendanceStudents()`: Identify students with low attendance

#### 4. **Advanced Queries**

- Join operations across multiple tables
- Aggregation and grouping for reports
- Complex analytics with subqueries
- Performance-optimized queries with indexes

## Usage Examples

#### Mark Attendance

```sql
INSERT INTO Attendance (student_id, course_id, date, status, marked_by)
VALUES (1, 1, CURRENT_DATE, 'Present', 1);
```

#### Get Attendance Report

```sql
CALL GetStudentAttendanceReport(1);
```

#### Find Low Attendance Students

```sql
CALL GetLowAttendanceStudents(75.00);
```

#### Department-wise Statistics

```sql
SELECT
    d.department_name,
    COUNT(DISTINCT s.student_id) as Total_Students,
    AVG(CASE WHEN a.status IN ('Present', 'Late') THEN 100.0 ELSE 0.0 END) as Avg_Attendance
FROM Departments d
LEFT JOIN Students s ON d.department_id = s.department_id
LEFT JOIN Attendance a ON s.student_id = a.student_id
GROUP BY d.department_id;
```

## Requirements

#### Functional Requirements

- [x] Multi-entity database design (Students, Faculty, Courses, Departments)
- [x] Proper normalization up to 3NF
- [x] Complete CRUD operations
- [x] JOIN operations with aggregation and grouping
- [x] Triggers for audit logging and validation
- [x] Stored procedures for complex operations
- [x] Comprehensive constraints and data integrity

#### Technical Requirements

- [x] MySQL database with proper schema design
- [x] Foreign key relationships with referential integrity
- [x] Indexes for performance optimization
- [x] Sample data for testing and demonstration
- [x] Comprehensive documentation and user manual

## Academic Context

**Course**: BCS403 – DBMS Lab
**Type**: Mini Project
**Focus Areas**:

- Database design and normalization
- SQL operations and advanced queries
- Triggers and stored procedures
- Data integrity and constraints
- Performance optimization

## License

[MIT](https://github.com/iamanjali1003/student-attendance-management-system/blob/main/LICENSE)
