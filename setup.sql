-- Master Setup Script for Student Attendance Management System

-- Create database
CREATE DATABASE IF NOT EXISTS student_attendance_db;
USE student_attendance_db;

-- Display setup information
SELECT 'Starting Student Attendance Management System Setup...' AS Status;

-- ========================================
-- 1. Create Tables and Schema
-- ========================================
SELECT 'Step 1: Creating database schema...' AS Status;
SOURCE database/schema.sql;

-- ========================================
-- 2. Create Triggers
-- ========================================
SELECT 'Step 2: Creating triggers...' AS Status;
SOURCE database/triggers.sql;

-- ========================================
-- 3. Create Stored Procedures
-- ========================================
SELECT 'Step 3: Creating stored procedures...' AS Status;
SOURCE database/procedures.sql;

-- ========================================
-- 4. Insert Sample Data
-- ========================================
SELECT 'Step 4: Inserting sample data...' AS Status;
SOURCE database/sample_data.sql;

-- ========================================
-- 5. Verify Setup
-- ========================================
SELECT 'Step 5: Verifying setup...' AS Status;

-- Check table creation
SELECT
    TABLE_NAME as 'Created Tables',
    TABLE_ROWS as 'Row Count'
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'student_attendance_db'
ORDER BY TABLE_NAME;

-- Check triggers
SELECT
    TRIGGER_NAME as 'Created Triggers',
    EVENT_MANIPULATION as 'Event',
    EVENT_OBJECT_TABLE as 'Table'
FROM INFORMATION_SCHEMA.TRIGGERS
WHERE TRIGGER_SCHEMA = 'student_attendance_db'
ORDER BY TRIGGER_NAME;

-- Check procedures
SELECT
    ROUTINE_NAME as 'Created Procedures',
    ROUTINE_TYPE as 'Type'
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = 'student_attendance_db'
ORDER BY ROUTINE_NAME;

-- ========================================
-- 6. Quick Test
-- ========================================
SELECT 'Step 6: Running quick tests...' AS Status;

-- Test basic data retrieval
SELECT 'Basic Data Test:' AS Test_Type;
SELECT COUNT(*) as Total_Students FROM Students;
SELECT COUNT(*) as Total_Courses FROM Courses;
SELECT COUNT(*) as Total_Attendance_Records FROM Attendance;

-- Test a simple join
SELECT 'Join Test:' AS Test_Type;
SELECT
    s.name AS Student,
    c.course_name AS Course,
    a.status AS Status
FROM Students s
JOIN Attendance a ON s.student_id = a.student_id
JOIN Courses c ON a.course_id = c.course_id
LIMIT 5;

-- Test procedure call
SELECT 'Procedure Test:' AS Test_Type;
CALL CalculateAttendancePercentage(1, 1, @percentage, @total, @present);
SELECT @percentage AS Sample_Attendance_Percentage;

SELECT 'Setup completed successfully!' AS Status;
SELECT 'You can now run queries from the queries/ directory' AS Next_Steps;