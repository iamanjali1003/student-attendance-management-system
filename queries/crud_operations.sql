-- CRUD Operations for Student Attendance Management System

-- ========================================
-- INSERT Operations (CREATE)
-- ========================================

-- Insert a new department
INSERT INTO Departments (department_name)
VALUES ('Robotics and Automation');

-- Insert a new faculty member
INSERT INTO Faculty (name, department_id, email, phone)
VALUES ('Dr. John Doe', 1, 'john.doe@college.edu', '9876543215');

-- Insert a new student
INSERT INTO Students (name, department_id, email, roll_number, phone)
VALUES ('Amit Kumar', 1, 'amit.kumar@student.edu', 'CS2024001', '8765432111');

-- Insert a new course
INSERT INTO Courses (course_name, course_code, faculty_id, department_id, credits)
VALUES ('Machine Learning', 'BCS701', 1, 1, 4);

-- Insert course enrollment
INSERT INTO Course_Enrollments (student_id, course_id, enrollment_date)
VALUES (1, 1, '2024-01-15');

-- Insert attendance record
INSERT INTO Attendance (student_id, course_id, date, status, marked_by)
VALUES (1, 1, '2024-01-29', 'Present', 1);

-- Bulk insert attendance for multiple students
INSERT INTO Attendance (student_id, course_id, date, status, marked_by) VALUES
(2, 1, '2024-01-29', 'Present', 1),
(3, 1, '2024-01-29', 'Late', 1),
(6, 1, '2024-01-29', 'Absent', 1);

-- ========================================
-- SELECT Operations (READ)
-- ========================================

-- Basic SELECT: Get all students
SELECT * FROM Students;

-- SELECT with WHERE: Get students from Computer Science department
SELECT s.*, d.department_name
FROM Students s
JOIN Departments d ON s.department_id = d.department_id
WHERE d.department_name = 'Computer Science';

-- SELECT with JOIN: Get student attendance with course and faculty details
SELECT
    s.name AS student_name,
    s.roll_number,
    c.course_name,
    c.course_code,
    f.name AS faculty_name,
    a.date,
    a.status
FROM Students s
JOIN Attendance a ON s.student_id = a.student_id
JOIN Courses c ON a.course_id = c.course_id
JOIN Faculty f ON c.faculty_id = f.faculty_id
ORDER BY a.date DESC, s.name;

-- SELECT with aggregation: Get attendance count by status
SELECT
    status,
    COUNT(*) as count
FROM Attendance
GROUP BY status;

-- SELECT with GROUP BY: Get attendance summary by student
SELECT
    s.name AS student_name,
    s.roll_number,
    COUNT(a.attendance_id) AS total_classes,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_count,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absent_count,
    SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END) AS late_count,
    ROUND(
        (SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) * 100.0) /
        COUNT(a.attendance_id), 2
    ) AS attendance_percentage
FROM Students s
LEFT JOIN Attendance a ON s.student_id = a.student_id
GROUP BY s.student_id, s.name, s.roll_number
ORDER BY attendance_percentage DESC;

-- SELECT with multiple JOINs: Get course-wise attendance summary
SELECT
    c.course_name,
    c.course_code,
    f.name AS faculty_name,
    d.department_name,
    COUNT(DISTINCT ce.student_id) AS enrolled_students,
    COUNT(a.attendance_id) AS total_attendance_records,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_count,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absent_count,
    SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END) AS late_count
FROM Courses c
JOIN Faculty f ON c.faculty_id = f.faculty_id
JOIN Departments d ON c.department_id = d.department_id
LEFT JOIN Course_Enrollments ce ON c.course_id = ce.course_id
LEFT JOIN Attendance a ON c.course_id = a.course_id
GROUP BY c.course_id, c.course_name, c.course_code, f.name, d.department_name
ORDER BY c.course_name;

-- SELECT with date filtering: Get today's attendance
SELECT
    s.name AS student_name,
    s.roll_number,
    c.course_name,
    a.status,
    a.created_at
FROM Attendance a
JOIN Students s ON a.student_id = s.student_id
JOIN Courses c ON a.course_id = c.course_id
WHERE a.date = CURRENT_DATE
ORDER BY c.course_name, s.name;

-- ========================================
-- UPDATE Operations
-- ========================================

-- Update student information
UPDATE Students
SET phone = '9999999999', email = 'rahul.verma.new@student.edu'
WHERE student_id = 1;

-- Update attendance status
UPDATE Attendance
SET status = 'Present', marked_by = 1
WHERE student_id = 2 AND course_id = 1 AND date = '2024-01-29';

-- Update faculty department
UPDATE Faculty
SET department_id = 2
WHERE faculty_id = 1;

-- Update course credits
UPDATE Courses
SET credits = 5
WHERE course_code = 'BCS403';

-- Bulk update: Mark all absent students as late for a specific date
UPDATE Attendance
SET status = 'Late'
WHERE date = '2024-01-22' AND status = 'Absent';

-- Update with JOIN: Update attendance based on course
UPDATE Attendance a
JOIN Courses c ON a.course_id = c.course_id
SET a.status = 'Present'
WHERE c.course_code = 'BCS403'
AND a.date = '2024-01-23'
AND a.status = 'Late';

-- ========================================
-- DELETE Operations
-- ========================================

-- Delete a specific attendance record
DELETE FROM Attendance
WHERE student_id = 3 AND course_id = 2 AND date = '2024-01-01';

-- Delete all attendance records for a specific date
DELETE FROM Attendance
WHERE date = '2024-01-01';

-- Delete student (will cascade to related records due to foreign key constraints)
-- DELETE FROM Students WHERE student_id = 10;

-- Delete course enrollment
DELETE FROM Course_Enrollments
WHERE student_id = 5 AND course_id = 3;

-- Delete with condition: Remove old attendance logs (older than 1 year)
DELETE FROM Attendance_Log
WHERE changed_at < DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR);

-- ========================================
-- Advanced SELECT Queries with Joins and Aggregates
-- ========================================

-- Complex query: Students with low attendance (below 75%)
SELECT
    s.student_id,
    s.name AS student_name,
    s.roll_number,
    d.department_name,
    c.course_name,
    COUNT(a.attendance_id) AS total_classes,
    SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) AS attended_classes,
    ROUND(
        (SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) * 100.0) /
        COUNT(a.attendance_id), 2
    ) AS attendance_percentage
FROM Students s
JOIN Departments d ON s.department_id = d.department_id
JOIN Course_Enrollments ce ON s.student_id = ce.student_id
JOIN Courses c ON ce.course_id = c.course_id
JOIN Attendance a ON s.student_id = a.student_id AND c.course_id = a.course_id
WHERE ce.status = 'Active'
GROUP BY s.student_id, c.course_id
HAVING attendance_percentage < 75
ORDER BY attendance_percentage ASC;

-- Monthly attendance report
SELECT
    YEAR(a.date) AS year,
    MONTH(a.date) AS month,
    MONTHNAME(a.date) AS month_name,
    c.course_name,
    COUNT(a.attendance_id) AS total_records,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_count,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absent_count,
    SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END) AS late_count,
    ROUND(
        (SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) * 100.0) /
        COUNT(a.attendance_id), 2
    ) AS monthly_attendance_percentage
FROM Attendance a
JOIN Courses c ON a.course_id = c.course_id
GROUP BY YEAR(a.date), MONTH(a.date), c.course_id
ORDER BY year DESC, month DESC, c.course_name;

-- Faculty workload report
SELECT
    f.name AS faculty_name,
    f.email,
    d.department_name,
    COUNT(DISTINCT c.course_id) AS courses_taught,
    COUNT(DISTINCT ce.student_id) AS total_students,
    COUNT(a.attendance_id) AS attendance_records_managed
FROM Faculty f
JOIN Departments d ON f.department_id = d.department_id
LEFT JOIN Courses c ON f.faculty_id = c.faculty_id
LEFT JOIN Course_Enrollments ce ON c.course_id = ce.course_id
LEFT JOIN Attendance a ON c.course_id = a.course_id
GROUP BY f.faculty_id
ORDER BY courses_taught DESC, total_students DESC;