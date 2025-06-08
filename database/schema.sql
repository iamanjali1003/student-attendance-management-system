-- Student Attendance Management System Database Schema
-- Course: BCS403 – DBMS Lab
-- Type: Mini Project

-- Drop existing tables if they exist (for clean setup)
DROP TABLE IF EXISTS Attendance_Log;
DROP TABLE IF EXISTS Attendance;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Faculty;
DROP TABLE IF EXISTS Departments;

-- Create Departments table
CREATE TABLE Departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Faculty table
CREATE TABLE Faculty (
    faculty_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id) ON DELETE CASCADE
);

-- Create Students table
CREATE TABLE Students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    roll_number VARCHAR(20) UNIQUE,
    phone VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id) ON DELETE CASCADE
);

-- Create Courses table
CREATE TABLE Courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    faculty_id INT NOT NULL,
    department_id INT NOT NULL,
    credits INT DEFAULT 3 CHECK (credits > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (faculty_id) REFERENCES Faculty(faculty_id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id) ON DELETE CASCADE
);

-- Create Attendance table
CREATE TABLE Attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    date DATE NOT NULL,
    status ENUM('Present', 'Absent', 'Late') NOT NULL DEFAULT 'Absent',
    marked_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (marked_by) REFERENCES Faculty(faculty_id),
    UNIQUE KEY unique_attendance (student_id, course_id, date)
);

-- Create Attendance_Log table for trigger logging
CREATE TABLE Attendance_Log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    attendance_id INT,
    student_id INT,
    course_id INT,
    date DATE,
    old_status ENUM('Present', 'Absent', 'Late'),
    new_status ENUM('Present', 'Absent', 'Late'),
    action_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    changed_by INT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Course Enrollment table (Many-to-Many relationship)
CREATE TABLE Course_Enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE DEFAULT (CURRENT_DATE),
    status ENUM('Active', 'Dropped', 'Completed') DEFAULT 'Active',
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE,
    UNIQUE KEY unique_enrollment (student_id, course_id)
);

-- Add indexes for better performance
CREATE INDEX idx_attendance_date ON Attendance(date);
CREATE INDEX idx_attendance_student ON Attendance(student_id);
CREATE INDEX idx_attendance_course ON Attendance(course_id);
CREATE INDEX idx_students_department ON Students(department_id);
CREATE INDEX idx_faculty_department ON Faculty(department_id);
CREATE INDEX idx_courses_faculty ON Courses(faculty_id); 