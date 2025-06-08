-- Sample Data for Student Attendance Management System
-- This file contains INSERT statements to populate the database with test data

-- Insert Departments
INSERT INTO Departments (department_name) VALUES
('Computer Science'),
('Information Science'),
('Electronics'),
('Mechanical Engineering'),
('Civil Engineering');

-- Insert Faculty
INSERT INTO Faculty (name, department_id, email, phone) VALUES
('Dr. Rajesh Kumar', 1, 'rajesh.kumar@college.edu', '9876543210'),
('Prof. Priya Sharma', 1, 'priya.sharma@college.edu', '9876543211'),
('Dr. Amit Singh', 2, 'amit.singh@college.edu', '9876543212'),
('Prof. Sunita Gupta', 2, 'sunita.gupta@college.edu', '9876543213'),
('Dr. Vikram Patel', 3, 'vikram.patel@college.edu', '9876543214');

-- Insert Students
INSERT INTO Students (name, department_id, email, roll_number, phone) VALUES
('Rahul Verma', 1, 'rahul.verma@student.edu', 'CS2021001', '8765432101'),
('Sneha Agarwal', 1, 'sneha.agarwal@student.edu', 'CS2021002', '8765432102'),
('Arjun Reddy', 1, 'arjun.reddy@student.edu', 'CS2021003', '8765432103'),
('Pooja Mehta', 2, 'pooja.mehta@student.edu', 'IT2021001', '8765432104'),
('Karan Joshi', 2, 'karan.joshi@student.edu', 'IT2021002', '8765432105'),
('Riya Kapoor', 1, 'riya.kapoor@student.edu', 'CS2021004', '8765432106'),
('Deepak Yadav', 2, 'deepak.yadav@student.edu', 'IT2021003', '8765432107'),
('Anita Desai', 3, 'anita.desai@student.edu', 'EC2021001', '8765432108'),
('Rohit Sharma', 1, 'rohit.sharma@student.edu', 'CS2021005', '8765432109'),
('Kavya Nair', 2, 'kavya.nair@student.edu', 'IT2021004', '8765432110');

-- Insert Courses
INSERT INTO Courses (course_name, course_code, faculty_id, department_id, credits) VALUES
('Database Management Systems', 'BCS403', 1, 1, 4),
('Data Structures and Algorithms', 'BCS301', 2, 1, 4),
('Web Development', 'BIT401', 3, 2, 3),
('Computer Networks', 'BCS501', 1, 1, 3),
('Software Engineering', 'BCS601', 2, 1, 4),
('Mobile App Development', 'BIT501', 4, 2, 3),
('Digital Electronics', 'BEC301', 5, 3, 4);

-- Insert Course Enrollments
INSERT INTO Course_Enrollments (student_id, course_id, enrollment_date) VALUES
-- CS students enrolled in CS courses
(1, 1, '2024-01-15'), (1, 2, '2024-01-15'), (1, 4, '2024-01-15'), (1, 5, '2024-01-15'),
(2, 1, '2024-01-15'), (2, 2, '2024-01-15'), (2, 4, '2024-01-15'), (2, 5, '2024-01-15'),
(3, 1, '2024-01-15'), (3, 2, '2024-01-15'), (3, 4, '2024-01-15'),
(6, 1, '2024-01-15'), (6, 2, '2024-01-15'), (6, 5, '2024-01-15'),
(9, 1, '2024-01-15'), (9, 2, '2024-01-15'), (9, 4, '2024-01-15'), (9, 5, '2024-01-15'),

-- IT students enrolled in IT and some CS courses
(4, 3, '2024-01-15'), (4, 6, '2024-01-15'), (4, 1, '2024-01-15'),
(5, 3, '2024-01-15'), (5, 6, '2024-01-15'), (5, 2, '2024-01-15'),
(7, 3, '2024-01-15'), (7, 6, '2024-01-15'), (7, 1, '2024-01-15'),
(10, 3, '2024-01-15'), (10, 6, '2024-01-15'),

-- EC student
(8, 7, '2024-01-15');

-- Insert Sample Attendance Data (for the past month)
INSERT INTO Attendance (student_id, course_id, date, status, marked_by) VALUES
-- Week 1 (Jan 1-5, 2024)
(1, 1, '2024-01-01', 'Present', 1),
(1, 2, '2024-01-02', 'Present', 2),
(1, 4, '2024-01-03', 'Late', 1),
(1, 5, '2024-01-04', 'Present', 2),
(2, 1, '2024-01-01', 'Present', 1),
(2, 2, '2024-01-02', 'Absent', 2),
(2, 4, '2024-01-03', 'Present', 1),
(2, 5, '2024-01-04', 'Present', 2),
(3, 1, '2024-01-01', 'Present', 1),
(3, 2, '2024-01-02', 'Present', 2),
(3, 4, '2024-01-03', 'Present', 1),

-- Week 2 (Jan 8-12, 2024)
(1, 1, '2024-01-08', 'Present', 1),
(1, 2, '2024-01-09', 'Present', 2),
(1, 4, '2024-01-10', 'Present', 1),
(1, 5, '2024-01-11', 'Late', 2),
(2, 1, '2024-01-08', 'Absent', 1),
(2, 2, '2024-01-09', 'Present', 2),
(2, 4, '2024-01-10', 'Present', 1),
(2, 5, '2024-01-11', 'Present', 2),
(3, 1, '2024-01-08', 'Present', 1),
(3, 2, '2024-01-09', 'Present', 2),
(3, 4, '2024-01-10', 'Present', 1),

-- IT Students attendance
(4, 3, '2024-01-01', 'Present', 3),
(4, 6, '2024-01-02', 'Present', 4),
(4, 1, '2024-01-01', 'Present', 1),
(5, 3, '2024-01-01', 'Late', 3),
(5, 6, '2024-01-02', 'Present', 4),
(5, 2, '2024-01-02', 'Present', 2),

-- More recent attendance (Jan 15-19, 2024)
(1, 1, '2024-01-15', 'Present', 1),
(1, 2, '2024-01-16', 'Present', 2),
(1, 4, '2024-01-17', 'Present', 1),
(1, 5, '2024-01-18', 'Present', 2),
(2, 1, '2024-01-15', 'Present', 1),
(2, 2, '2024-01-16', 'Present', 2),
(2, 4, '2024-01-17', 'Absent', 1),
(2, 5, '2024-01-18', 'Present', 2),
(3, 1, '2024-01-15', 'Present', 1),
(3, 2, '2024-01-16', 'Late', 2),
(3, 4, '2024-01-17', 'Present', 1),

-- Current week attendance (Jan 22-26, 2024)
(1, 1, '2024-01-22', 'Present', 1),
(1, 2, '2024-01-23', 'Present', 2),
(2, 1, '2024-01-22', 'Present', 1),
(2, 2, '2024-01-23', 'Absent', 2),
(3, 1, '2024-01-22', 'Late', 1),
(3, 2, '2024-01-23', 'Present', 2),
(6, 1, '2024-01-22', 'Present', 1),
(6, 2, '2024-01-23', 'Present', 2),
(9, 1, '2024-01-22', 'Present', 1),
(9, 2, '2024-01-23', 'Present', 2); 