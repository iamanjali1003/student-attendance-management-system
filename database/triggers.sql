-- Triggers for Student Attendance Management System
-- These triggers handle logging of attendance changes and student deletions

DELIMITER //

-- Trigger 1: Log attendance updates
CREATE TRIGGER attendance_update_log
    AFTER UPDATE ON Attendance
    FOR EACH ROW
BEGIN
    INSERT INTO Attendance_Log (
        attendance_id,
        student_id,
        course_id,
        date,
        old_status,
        new_status,
        action_type,
        changed_by
    ) VALUES (
        NEW.attendance_id,
        NEW.student_id,
        NEW.course_id,
        NEW.date,
        OLD.status,
        NEW.status,
        'UPDATE',
        NEW.marked_by
    );
END//

-- Trigger 2: Log attendance insertions
CREATE TRIGGER attendance_insert_log
    AFTER INSERT ON Attendance
    FOR EACH ROW
BEGIN
    INSERT INTO Attendance_Log (
        attendance_id,
        student_id,
        course_id,
        date,
        old_status,
        new_status,
        action_type,
        changed_by
    ) VALUES (
        NEW.attendance_id,
        NEW.student_id,
        NEW.course_id,
        NEW.date,
        NULL,
        NEW.status,
        'INSERT',
        NEW.marked_by
    );
END//

-- Trigger 3: Log attendance deletions
CREATE TRIGGER attendance_delete_log
    BEFORE DELETE ON Attendance
    FOR EACH ROW
BEGIN
    INSERT INTO Attendance_Log (
        attendance_id,
        student_id,
        course_id,
        date,
        old_status,
        new_status,
        action_type,
        changed_by
    ) VALUES (
        OLD.attendance_id,
        OLD.student_id,
        OLD.course_id,
        OLD.date,
        OLD.status,
        NULL,
        'DELETE',
        OLD.marked_by
    );
END//

-- Trigger 4: Log student deletions (cascade information)
CREATE TRIGGER student_delete_log
    BEFORE DELETE ON Students
    FOR EACH ROW
BEGIN
    -- Log the student deletion with their enrollment information
    INSERT INTO Attendance_Log (
        attendance_id,
        student_id,
        course_id,
        date,
        old_status,
        new_status,
        action_type,
        changed_by
    ) VALUES (
        NULL,
        OLD.student_id,
        NULL,
        CURRENT_DATE,
        NULL,
        NULL,
        'DELETE',
        NULL
    );
END//

-- Trigger 5: Validate attendance date (cannot be future date)
CREATE TRIGGER validate_attendance_date
    BEFORE INSERT ON Attendance
    FOR EACH ROW
BEGIN
    IF NEW.date > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Attendance cannot be marked for future dates';
    END IF;
END//

-- Trigger 6: Auto-update attendance timestamp
CREATE TRIGGER update_attendance_timestamp
    BEFORE UPDATE ON Attendance
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END//

DELIMITER ; 