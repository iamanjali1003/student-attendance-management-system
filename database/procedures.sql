-- Stored Procedures for Student Attendance Management System

DELIMITER //

-- Procedure 1: Calculate attendance percentage for a student in a specific course
CREATE PROCEDURE CalculateAttendancePercentage(
    IN p_student_id INT,
    IN p_course_id INT,
    OUT p_percentage DECIMAL(5,2),
    OUT p_total_classes INT,
    OUT p_present_classes INT
)
BEGIN
    DECLARE total_count INT DEFAULT 0;
    DECLARE present_count INT DEFAULT 0;

    -- Get total classes for the student in the course
    SELECT COUNT(*) INTO total_count
    FROM Attendance
    WHERE student_id = p_student_id AND course_id = p_course_id;

    -- Get present classes (Present + Late are considered as attended)
    SELECT COUNT(*) INTO present_count
    FROM Attendance
    WHERE student_id = p_student_id
    AND course_id = p_course_id
    AND status IN ('Present', 'Late');

    -- Calculate percentage
    IF total_count > 0 THEN
        SET p_percentage = (present_count * 100.0) / total_count;
    ELSE
        SET p_percentage = 0.0;
    END IF;

    SET p_total_classes = total_count;
    SET p_present_classes = present_count;
END//

-- Procedure 2: Get attendance percentage for all courses of a student
CREATE PROCEDURE GetStudentAttendanceReport(IN p_student_id INT)
BEGIN
    SELECT
        s.name AS student_name,
        s.roll_number,
        c.course_name,
        c.course_code,
        COUNT(a.attendance_id) AS total_classes,
        SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) AS attended_classes,
        ROUND(
            (SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) * 100.0) /
            COUNT(a.attendance_id), 2
        ) AS attendance_percentage
    FROM Students s
    JOIN Course_Enrollments ce ON s.student_id = ce.student_id
    JOIN Courses c ON ce.course_id = c.course_id
    LEFT JOIN Attendance a ON s.student_id = a.student_id AND c.course_id = a.course_id
    WHERE s.student_id = p_student_id
    GROUP BY s.student_id, c.course_id
    ORDER BY c.course_name;
END//

-- Procedure 3: Auto-mark absent for unmarked students by day-end
CREATE PROCEDURE AutoMarkAbsent(IN p_date DATE, IN p_course_id INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_student_id INT;

    -- Cursor to get all enrolled students for the course who don't have attendance for the date
    DECLARE student_cursor CURSOR FOR
        SELECT ce.student_id
        FROM Course_Enrollments ce
        WHERE ce.course_id = p_course_id
        AND ce.status = 'Active'
        AND ce.student_id NOT IN (
            SELECT a.student_id
            FROM Attendance a
            WHERE a.course_id = p_course_id
            AND a.date = p_date
        );

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN student_cursor;

    read_loop: LOOP
        FETCH student_cursor INTO v_student_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Insert absent record for the student
        INSERT INTO Attendance (student_id, course_id, date, status, marked_by)
        VALUES (v_student_id, p_course_id, p_date, 'Absent', NULL);
    END LOOP;

    CLOSE student_cursor;

    -- Return count of students marked absent
    SELECT ROW_COUNT() as students_marked_absent;
END//

-- Procedure 4: Get course attendance summary
CREATE PROCEDURE GetCourseAttendanceSummary(IN p_course_id INT, IN p_date DATE)
BEGIN
    SELECT
        c.course_name,
        c.course_code,
        f.name AS faculty_name,
        p_date AS attendance_date,
        COUNT(ce.student_id) AS total_enrolled,
        SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_count,
        SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absent_count,
        SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END) AS late_count,
        ROUND(
            (SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) * 100.0) /
            COUNT(ce.student_id), 2
        ) AS attendance_percentage
    FROM Courses c
    JOIN Faculty f ON c.faculty_id = f.faculty_id
    JOIN Course_Enrollments ce ON c.course_id = ce.course_id
    LEFT JOIN Attendance a ON ce.student_id = a.student_id
        AND ce.course_id = a.course_id
        AND a.date = p_date
    WHERE c.course_id = p_course_id
    AND ce.status = 'Active'
    GROUP BY c.course_id;
END//

-- Procedure 5: Mark attendance for multiple students at once
CREATE PROCEDURE BulkMarkAttendance(
    IN p_course_id INT,
    IN p_date DATE,
    IN p_student_ids TEXT,  -- Comma-separated student IDs
    IN p_status ENUM('Present', 'Absent', 'Late'),
    IN p_marked_by INT
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_student_id INT;
    DECLARE v_pos INT DEFAULT 1;
    DECLARE v_next_pos INT;
    DECLARE v_student_id_str VARCHAR(10);

    -- Process comma-separated student IDs
    WHILE v_pos <= LENGTH(p_student_ids) DO
        SET v_next_pos = LOCATE(',', p_student_ids, v_pos);

        IF v_next_pos = 0 THEN
            SET v_next_pos = LENGTH(p_student_ids) + 1;
        END IF;

        SET v_student_id_str = TRIM(SUBSTRING(p_student_ids, v_pos, v_next_pos - v_pos));
        SET v_student_id = CAST(v_student_id_str AS UNSIGNED);

        -- Insert or update attendance
        INSERT INTO Attendance (student_id, course_id, date, status, marked_by)
        VALUES (v_student_id, p_course_id, p_date, p_status, p_marked_by)
        ON DUPLICATE KEY UPDATE
            status = p_status,
            marked_by = p_marked_by,
            updated_at = CURRENT_TIMESTAMP;

        SET v_pos = v_next_pos + 1;
    END WHILE;

    SELECT CONCAT('Attendance marked for ', ROW_COUNT(), ' students') AS result;
END//

-- Procedure 6: Get low attendance students (below threshold)
CREATE PROCEDURE GetLowAttendanceStudents(IN p_threshold DECIMAL(5,2))
BEGIN
    SELECT
        s.student_id,
        s.name AS student_name,
        s.roll_number,
        c.course_name,
        c.course_code,
        COUNT(a.attendance_id) AS total_classes,
        SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) AS attended_classes,
        ROUND(
            (SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) * 100.0) /
            COUNT(a.attendance_id), 2
        ) AS attendance_percentage
    FROM Students s
    JOIN Course_Enrollments ce ON s.student_id = ce.student_id
    JOIN Courses c ON ce.course_id = c.course_id
    JOIN Attendance a ON s.student_id = a.student_id AND c.course_id = a.course_id
    WHERE ce.status = 'Active'
    GROUP BY s.student_id, c.course_id
    HAVING attendance_percentage < p_threshold
    ORDER BY attendance_percentage ASC, s.name;
END//

DELIMITER ;