-- Test Queries for Student Attendance Management System
-- This file contains queries to test all features and generate sample outputs

-- ========================================
-- 1. Testing Basic CRUD Operations
-- ========================================

-- Test 1: View all tables data
SELECT 'Departments' as table_name, COUNT(*) as record_count FROM Departments
UNION ALL
SELECT 'Faculty', COUNT(*) FROM Faculty
UNION ALL
SELECT 'Students', COUNT(*) FROM Students
UNION ALL
SELECT 'Courses', COUNT(*) FROM Courses
UNION ALL
SELECT 'Course_Enrollments', COUNT(*) FROM Course_Enrollments
UNION ALL
SELECT 'Attendance', COUNT(*) FROM Attendance
UNION ALL
SELECT 'Attendance_Log', COUNT(*) FROM Attendance_Log;

-- ========================================
-- 2. Testing Joins and Aggregations
-- ========================================

-- Test 2: Student-Course-Faculty Join
SELECT 
    s.name AS Student,
    s.roll_number AS RollNo,
    c.course_name AS Course,
    f.name AS Faculty,
    d.department_name AS Department
FROM Students s
JOIN Course_Enrollments ce ON s.student_id = ce.student_id
JOIN Courses c ON ce.course_id = c.course_id
JOIN Faculty f ON c.faculty_id = f.faculty_id
JOIN Departments d ON s.department_id = d.department_id
ORDER BY s.name;

-- Test 3: Attendance Summary with Aggregation
SELECT 
    s.name AS Student_Name,
    c.course_name AS Course,
    COUNT(a.attendance_id) AS Total_Classes,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS Present,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS Absent,
    SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END) AS Late,
    ROUND(
        (SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(a.attendance_id), 2
    ) AS Attendance_Percentage
FROM Students s
JOIN Attendance a ON s.student_id = a.student_id
JOIN Courses c ON a.course_id = c.course_id
GROUP BY s.student_id, c.course_id
ORDER BY Attendance_Percentage DESC;

-- ========================================
-- 3. Testing Stored Procedures
-- ========================================

-- Test 4: Call attendance percentage calculation procedure
CALL CalculateAttendancePercentage(1, 1, @percentage, @total, @present);
SELECT 
    'Student ID 1, Course ID 1' AS Test_Case,
    @percentage AS Attendance_Percentage,
    @total AS Total_Classes,
    @present AS Present_Classes;

-- Test 5: Get student attendance report
CALL GetStudentAttendanceReport(1);

-- Test 6: Get course attendance summary for a specific date
CALL GetCourseAttendanceSummary(1, '2024-01-22');

-- Test 7: Get low attendance students (below 80%)
CALL GetLowAttendanceStudents(80.00);

-- ========================================
-- 4. Testing Triggers (Insert/Update/Delete)
-- ========================================

-- Test 8: Insert new attendance record (should trigger log)
INSERT INTO Attendance (student_id, course_id, date, status, marked_by) 
VALUES (1, 2, '2024-01-30', 'Present', 2);

-- Check if trigger logged the insertion
SELECT 'After INSERT trigger test' AS Test_Description;
SELECT * FROM Attendance_Log WHERE action_type = 'INSERT' ORDER BY changed_at DESC LIMIT 5;

-- Test 9: Update attendance record (should trigger log)
UPDATE Attendance 
SET status = 'Late' 
WHERE student_id = 1 AND course_id = 2 AND date = '2024-01-30';

-- Check if trigger logged the update
SELECT 'After UPDATE trigger test' AS Test_Description;
SELECT * FROM Attendance_Log WHERE action_type = 'UPDATE' ORDER BY changed_at DESC LIMIT 5;

-- ========================================
-- 5. Advanced Reporting Queries
-- ========================================

-- Test 10: Department-wise attendance statistics
SELECT 
    d.department_name AS Department,
    COUNT(DISTINCT s.student_id) AS Total_Students,
    COUNT(DISTINCT c.course_id) AS Total_Courses,
    COUNT(a.attendance_id) AS Total_Attendance_Records,
    ROUND(AVG(
        CASE WHEN a.status IN ('Present', 'Late') THEN 100.0 ELSE 0.0 END
    ), 2) AS Avg_Attendance_Rate
FROM Departments d
LEFT JOIN Students s ON d.department_id = s.department_id
LEFT JOIN Courses c ON d.department_id = c.department_id
LEFT JOIN Attendance a ON s.student_id = a.student_id
GROUP BY d.department_id, d.department_name
ORDER BY Avg_Attendance_Rate DESC;

-- Test 11: Daily attendance trend
SELECT 
    a.date AS Date,
    COUNT(a.attendance_id) AS Total_Records,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS Present_Count,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS Absent_Count,
    SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END) AS Late_Count,
    ROUND(
        (SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(a.attendance_id), 2
    ) AS Daily_Attendance_Rate
FROM Attendance a
GROUP BY a.date
ORDER BY a.date DESC;

-- Test 12: Faculty performance report
SELECT 
    f.name AS Faculty_Name,
    COUNT(DISTINCT c.course_id) AS Courses_Teaching,
    COUNT(DISTINCT s.student_id) AS Students_Handling,
    COUNT(a.attendance_id) AS Attendance_Records,
    ROUND(AVG(
        CASE WHEN a.status IN ('Present', 'Late') THEN 100.0 ELSE 0.0 END
    ), 2) AS Avg_Class_Attendance
FROM Faculty f
LEFT JOIN Courses c ON f.faculty_id = c.faculty_id
LEFT JOIN Course_Enrollments ce ON c.course_id = ce.course_id
LEFT JOIN Students s ON ce.student_id = s.student_id
LEFT JOIN Attendance a ON s.student_id = a.student_id AND c.course_id = a.course_id
GROUP BY f.faculty_id, f.name
ORDER BY Avg_Class_Attendance DESC;

-- ========================================
-- 6. Data Validation and Constraint Testing
-- ========================================

-- Test 13: Check referential integrity
SELECT 'Orphaned Records Check' AS Test_Type;

-- Check for students without departments
SELECT 'Students without departments' AS Issue, COUNT(*) AS Count
FROM Students s
LEFT JOIN Departments d ON s.department_id = d.department_id
WHERE d.department_id IS NULL;

-- Check for courses without faculty
SELECT 'Courses without faculty' AS Issue, COUNT(*) AS Count
FROM Courses c
LEFT JOIN Faculty f ON c.faculty_id = f.faculty_id
WHERE f.faculty_id IS NULL;

-- Check for attendance without students or courses
SELECT 'Attendance without valid student' AS Issue, COUNT(*) AS Count
FROM Attendance a
LEFT JOIN Students s ON a.student_id = s.student_id
WHERE s.student_id IS NULL;

-- ========================================
-- 7. Performance and Index Testing
-- ========================================

-- Test 14: Query performance test (with EXPLAIN)
EXPLAIN SELECT 
    s.name,
    c.course_name,
    a.date,
    a.status
FROM Students s
JOIN Attendance a ON s.student_id = a.student_id
JOIN Courses c ON a.course_id = c.course_id
WHERE a.date BETWEEN '2024-01-01' AND '2024-01-31'
ORDER BY a.date DESC;

-- ========================================
-- 8. Sample Output Queries for Documentation
-- ========================================

-- Test 15: Complete student profile with attendance
SELECT 
    s.student_id,
    s.name AS Student_Name,
    s.roll_number,
    s.email,
    d.department_name,
    GROUP_CONCAT(DISTINCT c.course_name ORDER BY c.course_name) AS Enrolled_Courses,
    COUNT(DISTINCT ce.course_id) AS Total_Courses,
    COUNT(a.attendance_id) AS Total_Classes_Attended,
    ROUND(AVG(
        CASE WHEN a.status IN ('Present', 'Late') THEN 100.0 ELSE 0.0 END
    ), 2) AS Overall_Attendance_Percentage
FROM Students s
JOIN Departments d ON s.department_id = d.department_id
LEFT JOIN Course_Enrollments ce ON s.student_id = ce.student_id
LEFT JOIN Courses c ON ce.course_id = c.course_id
LEFT JOIN Attendance a ON s.student_id = a.student_id AND c.course_id = a.course_id
GROUP BY s.student_id
ORDER BY Overall_Attendance_Percentage DESC;

-- Test 16: Attendance log analysis
SELECT 
    al.action_type AS Action,
    COUNT(*) AS Frequency,
    MIN(al.changed_at) AS First_Occurrence,
    MAX(al.changed_at) AS Last_Occurrence
FROM Attendance_Log al
GROUP BY al.action_type
ORDER BY Frequency DESC;

-- Test 17: Course enrollment statistics
SELECT 
    c.course_name,
    c.course_code,
    c.credits,
    f.name AS Faculty,
    COUNT(ce.student_id) AS Enrolled_Students,
    CASE 
        WHEN COUNT(ce.student_id) > 5 THEN 'High Enrollment'
        WHEN COUNT(ce.student_id) > 2 THEN 'Medium Enrollment'
        ELSE 'Low Enrollment'
    END AS Enrollment_Status
FROM Courses c
JOIN Faculty f ON c.faculty_id = f.faculty_id
LEFT JOIN Course_Enrollments ce ON c.course_id = ce.course_id AND ce.status = 'Active'
GROUP BY c.course_id
ORDER BY Enrolled_Students DESC; 