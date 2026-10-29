USE coding_bootcamp;
CREATE TABLE student (
student_id INT NOT NULL AUTO_INCREMENT,
first_name VARCHAR(45) NOT NULL,
last_name VARCHAR(45) NOT NULL,
email VARCHAR(60) NOT NULL,
PRIMARY KEY (student_id),
UNIQUE (email)
);

CREATE TABLE coach (
coach_id INT NOT NULL AUTO_INCREMENT,
first_name VARCHAR(45) NOT NULL,
last_name VARCHAR(45) NOT NULL,
email VARCHAR(60) NOT NULL,
PRIMARY KEY (coach_id),
UNIQUE (email)
);

CREATE TABLE professor (
professor_id INT NOT NULL AUTO_INCREMENT,
first_name VARCHAR(45) NOT NULL,
last_name VARCHAR(45) NOT NULL,
email VARCHAR(60),
shift ENUM('Day','Night'),
PRIMARY KEY (professor_id),
UNIQUE (email)	
);

CREATE TABLE unit (
unit_id INT NOT NULL AUTO_INCREMENT,
unit_name VARCHAR(60) NOT NULL,
sequence_no INT NOT NULL,
duration_weeks INT DEFAULT 2,
PRIMARY KEY (unit_id),
UNIQUE (unit_name), 
UNIQUE (sequence_no)
);

CREATE TABLE cohort (
cohort_id INT NOT NULL AUTO_INCREMENT,
coach_id INT NOT NULL,
shift ENUM('Day','Night'),
start_date DATE NOT NULL,
end_date DATE NOT NULL,
max_students INT DEFAULT 50,
PRIMARY KEY (cohort_id),
CONSTRAINT fk_cohort_coach
FOREIGN KEY (coach_id) REFERENCES coach (coach_id)
);

CREATE TABLE application (
app_id INT NOT NULL AUTO_INCREMENT,
student_id INT NOT NULL,
cohort_id INT NOT NULL,
application_date DATE NOT NULL,
exam_score DECIMAL(5,2),
exam_result ENUM ('Pass','Fail'),
approval_status ENUM ('Pending', 'Approved', 'Rejected') NOT NULL DEFAULT 'Pending',
PRIMARY KEY (app_id),
UNIQUE (student_id,cohort_id),
CONSTRAINT fk_application_student
FOREIGN KEY (student_id) REFERENCES student (student_id),
CONSTRAINT fk_application_cohort
FOREIGN KEY (cohort_id) REFERENCES cohort (cohort_id),
CHECK (exam_score BETWEEN 0 AND 100),
CHECK (approval_status <> 'Approved' OR exam_result <=> 'Pass')
);

CREATE TABLE cohort_unit (
cohort_id INT NOT NULL, 
unit_id INT NOT NULL, 
start_date DATE NOT NULL, 
end_date DATE NOT NULL,
professor_id INT NULL, 
PRIMARY KEY (cohort_id, unit_id),
CONSTRAINT fk_cohort_unit_cohort
FOREIGN KEY (cohort_id) REFERENCES cohort (cohort_id),
CONSTRAINT fk_cohort_unit_unit
FOREIGN KEY (unit_id) REFERENCES unit (unit_id),
CONSTRAINT fk_cohort_unit_professor
FOREIGN KEY (professor_id) REFERENCES professor (professor_id),
CHECK (end_date > start_date)
);

CREATE TABLE enrollment (
enrollment_id INT AUTO_INCREMENT,
student_id INT NOT NULL,
cohort_id INT NOT NULL, 
enrollment_date DATE NOT NULL,
status ENUM('Active','Dropped','Completed'),
pay_option ENUM('Full','Plan'),
final_result ENUM ('Pass', 'Fail'),
PRIMARY KEY (enrollment_id),
CONSTRAINT fk_enrollment_student
FOREIGN KEY (student_id) REFERENCES student(student_id),
CONSTRAINT fk_enrollment_cohort
FOREIGN KEY (cohort_id) REFERENCES cohort(cohort_id)
);

CREATE TABLE assignment (
assignment_id INT NOT NULL AUTO_INCREMENT,
cohort_id INT NOT NULL, 
professor_id INT NOT NULL,
title VARCHAR(100) NOT NULL,
type ENUM('Homework', 'Lab', 'Quiz', 'Mid-point', 'Final Project'),
assigned_date DATE NOT NULL,
due_date DATE NOT NULL,
max_points INT NOT NULL,
PRIMARY KEY (assignment_id),
CONSTRAINT fk_assignment_cohort
FOREIGN KEY (cohort_id) REFERENCES cohort(cohort_id),
CONSTRAINT fk_assignment_unit
FOREIGN KEY (unit_id) REFERENCES unit(unit_id),
CONSTRAINT fk_assignment_professor
FOREIGN KEY (professor_id) REFERENCES professor(professor_id),
CHECK (due_date >= assigned_date),
CHECK (max_points > 0),
UNIQUE (title)
);

CREATE TABLE submission (
student_id INT NOT NULL,
assignment_id INT NOT NULL, 
submitted_at DATETIME NOT NULL,
score DECIMAL(5,2),
PRIMARY KEY (student_id, assignment_id),
CONSTRAINT fk_submission_student
FOREIGN KEY (student_id) REFERENCES student(student_id),
CONSTRAINT fk_submission_assignment
FOREIGN KEY (assignment_id) REFERENCES assignment(assignment_id),
CHECK (score >= 0)
);

CREATE TABLE attendance (
attendance_id INT NOT NULL,
student_id INT NOT NULL,
date DATE NOT NULL, 
status ENUM('Present','Absent'),
excused_absence BOOLEAN,
PRIMARY KEY (attendance_id),
CONSTRAINT fk_attendance_student
FOREIGN KEY (student_id) REFERENCES student(student_id),
CHECK (excused_absence = FALSE OR status = 'Absent')
);

CREATE TABLE payment (
payment_id INT NOT NULL,
student_id INT NOT NULL,
installment_no TINYINT NOT NULL DEFAULT('1'),
amount_due DECIMAL(8,2) NOT NULL,
due_date DATE NOT NULL,
amount_paid DECIMAL(8,2) NOT NULL,
pay_date DATE NOT NULL,
pay_method ENUM('Credit','Debit'),
PRIMARY KEY (payment_id),
CONSTRAINT fk_payment_student
FOREIGN KEY (student_id) REFERENCES student(student_id),
CHECK (installment_no BETWEEN 1 AND 3),
CHECK (amount_due IN ('2000', '4000', '10000')),
CHECK (amount_paid <= amount_due),
CHECK (amount_paid >= 0)
);

CREATE TABLE tutoring_session (
tutoring_id INT NOT NULL AUTO_INCREMENT,
cohort_id INT NOT NULL,
unit_id INT NOT NULL, 
professor_id INT NOT NULL,
session_date DATE NOT NULL,
start_time TIME NOT NULL,
end_time TIME NOT NULL,
PRIMARY KEY (tutoring_id),
CONSTRAINT fk_tutoring_session_cohort
FOREIGN KEY (cohort_id) REFERENCES cohort(cohort_id),
CONSTRAINT fk_tutoring_session_unit
FOREIGN KEY (unit_id) REFERENCES unit(unit_id),
CONSTRAINT fk_tutoring_session_professor
FOREIGN KEY (professor_id) REFERENCES professor(professor_id),
CHECK (end_time > start_time),
CHECK (DAYOFWEEK(session_date) =7),
CHECK (start_time = '12:00:00' AND end_time = '14:00:00')
);

CREATE TABLE coaching_meeting (
meeting_id INT NOT NULL AUTO_INCREMENT,
student_id INT NOT NULL,
coach_id INT NOT NULL,
meeting_date DATE NOT NULL,
start_time TIME NOT NULL,
PRIMARY KEY (meeting_id),
CONSTRAINT fk_coaching_meeting_student
FOREIGN KEY (student_id) REFERENCES student(student_id),
CONSTRAINT fk_coaching_meeting_coach
FOREIGN KEY (coach_id) REFERENCES coach(coach_id)
);

CREATE TABLE tutoring_attendance (
tutoring_id INT NOT NULL,
student_id INT NOT NULL,
PRIMARY KEY (tutoring_id, student_id),
CONSTRAINT fk_tutoring_attendance_tutoring_session
FOREIGN KEY (tutoring_id) REFERENCES tutoring_session(tutoring_id),
CONSTRAINT fk_tutoring_attendance_student
FOREIGN KEY (student_id) REFERENCES student(student_id)
);

INSERT INTO student (student_id, first_name, last_name, email)
VALUES
(101, 'Jane', 'Doe', 'jane.doe@student.edu'),
(102, 'Jon', 'Doe', 'jon.doe@student.edu'),
(103, 'Alice', 'Smith', 'alice.smith@student.edu'),
(104,'Charlie','Brown','charlie.brown@student.edu');

INSERT INTO professor (professor_id, first_name, last_name, email, shift)
VALUES
(1, 'Elanor', 'Vance', 'e.vance@university.edu', 'Day'),
(2, 'Marcus', 'King', 'marc.king@university.edu', 'Night'),
(3, 'Bob', 'Jones', 'bob.jones@university.edu', 'Day'),
(4, 'James', 'Smith', 'james.smith@university.edu', 'Night'),
(5, 'Luke', 'Cage', 'luke.cage@university.edu', 'Day'),
(6, 'Wanda', 'Vision', 'wanda.vision@university.edu', 'Night'),
(7, 'Agatha', 'Hayes', 'agatha.hayes@university.edu', 'Day'),
(8, 'Miles', 'Morales', 'miles.morales@university.edu', 'Night'),
(9, 'Ezra', 'Fitz', 'ezra.fitz@university.edu', 'Day'),
(10, 'Mya', 'Thompson', 'mya.thompson@university.edu', 'Night');

INSERT INTO unit (unit_name, sequence_no, duration_weeks)
VALUES
('Python Foundations', 1, 2),
('HTML + CSS Basics', 2, 2),
('Javascript Foundations', 3, 2),
('Database Management: SQL Foundations', 4, 2),
('Introduction to Windows Terminal', 5, 2),
('Professional Development', 6, 2);

INSERT INTO coach (coach_id, first_name, last_name, email)
VALUES
(10,'Sarah','Connor','sarah.connor@university.edu'),
(20, 'David','Miller','d.miller@university.edu');

INSERT INTO cohort (cohort_id, coach_id, shift, start_date, end_date, max_students)
VALUES
(01, 10, 'Day', '2026-10-31', '2027-01-23', 50),
(02, 20, 'Night', '2026-11-07', '2027-01-23', 50);

UPDATE cohort
   SET start_date = '2026-11-02', end_date = '2027-01-22'
 WHERE cohort_id IN (01, 02);

ALTER TABLE application MODIFY exam_score DECIMAL(5,2) NULL;

INSERT INTO application (app_id, student_id, cohort_id, application_date, exam_score, exam_result, approval_status)
VALUES
(1001, 101, 01, '2026-09-30','92.50', 'Pass', 'Approved'),
(1002, 102, 02, '2026-08-27', '78.25', 'Pass', 'Approved'),
(1003, 103, 01, '2026-09-16', '55.00', 'Fail', 'Rejected'),
(1004, 104, 02, '2026-08-23', NULL, NULL, 'Pending');

DESCRIBE unit;

INSERT INTO cohort_unit (cohort_id, unit_id, start_date, end_date, professor_id)
VALUES
(01, 1, '2026-11-02', '2027-11-13', 1),
(02, 2, '2026-11-16', '2027-11-27', 2),
(01, 3, '2026-11-30', '2027-12-11', 3),
(02, 4, '2026-12-14', '2027-12-25', 4),
(01, 5, '2026-12-28', '2027-01-08', 5),
(02, 6, '2026-01-11', '2027-01-22', 6);

UPDATE application SET approval_status = 'Approved'
 WHERE student_id = 103 AND cohort_id = 01;

SELECT app_id, student_id, cohort_id, exam_score, exam_result, approval_status
FROM application
WHERE student_id = 103 AND cohort_id = 01;

UPDATE application
   SET exam_score = 78.25,
       exam_result = 'Pass',
       approval_status = 'Approved'
 WHERE student_id = 103 AND cohort_id = 1;
 
 ALTER TABLE enrollment MODIFY final_result ENUM('Pass','Fail') NULL;

INSERT INTO enrollment (enrollment_id, student_id, cohort_id, enrollment_date, status, pay_option, final_result)
VALUES
(001, 101, 01, '2026-10-17', 'Active', 'Full', NULL),
(002, 102, 02, '2026-10-17', 'Active','Full', NULL),
(003, 103, 01, '2026-10-17', 'Active','Full', NULL),
(004, 104, 02, '2026-10-17', 'Active','Full', NULL);

INSERT INTO assignment (cohort_id, professor_id, title, type, assigned_date, due_date, max_points)
VALUES
(01, 1, 'Homework 1', 'Homework', '2026-11-04', '2026-11-06', 60),
(02, 2, 'Homework 1', 'Homework', '2026-11-04', '2026-11-06', 60);

INSERT INTO submission (student_id, assignment_id, submitted_at, score)
VALUES
(101, 1, '2026-11-06 08:35:00', 54.00),
(102, 2, '2026-11-06 23:58:00',60.00);

INSERT INTO attendance (student_id, date, status, excused_absence)
VALUES
(101, '2026-11-02', 'Present', FALSE),
(102, '2026-11-02', 'Present', FALSE);

ALTER TABLE payment MODIFY payment_id INT NOT NULL AUTO_INCREMENT;

INSERT INTO payment (student_id, installment_no, amount_due, due_date, amount_paid, pay_date, pay_method)
VALUES
(101, '1', 10000, '2026-12-02', 10000, '2026-11-02', 'Credit');

INSERT INTO tutoring_session (cohort_id, unit_id, professor_id, session_date, start_time, end_time)
VALUES
(01, 1, 1, '2026-11-07', '12:00:00', '14:00:00');

INSERT INTO coaching_meeting (student_id, coach_id, meeting_date, start_time)
VALUES
(103, 10, '2026-11-19', '17:30:00');

SELECT tutoring_id, cohort_id, unit_id, session_date FROM tutoring_session;

INSERT INTO tutoring_attendance (tutoring_id, student_id)
VALUES
(1, 104);

INSERT INTO cohort (coach_id, shift, start_date, end_date, max_students)
VALUES (20, 'Day', '2027-02-01', '2027-04-23', 50);

DELETE FROM cohort WHERE start_date = '2027-02-01';
SHOW TRIGGERS;

SELECT coach_id, shift FROM coach;
ALTER TABLE coach ADD COLUMN shift ENUM('Day','Night') NOT NULL;

SELECT coach_id, shift FROM coach;

UPDATE coach SET shift = 'Day'   WHERE coach_id = 10;
UPDATE coach SET shift = 'Night' WHERE coach_id = 20;

DESCRIBE professor;

INSERT INTO cohort (coach_id, shift, start_date, end_date, max_students)
VALUES (20, 'Day', '2027-02-01', '2027-04-23', 50);

DELETE FROM cohort WHERE start_date = '2027-02-01';
SHOW TRIGGERS;

SET SQL_SAFE_UPDATES = 0;
DELETE FROM cohort WHERE start_date = '2027-02-01';
SET SQL_SAFE_UPDATES = 1;

SHOW CREATE TRIGGER cohort_BEFORE_INSERT;
DELIMITER $$

CREATE TRIGGER cohort_BEFORE_INSERT
BEFORE INSERT ON cohort
FOR EACH ROW
BEGIN
  DECLARE coach_shift VARCHAR(10);

  SELECT shift INTO coach_shift
    FROM coach
   WHERE coach_id = NEW.coach_id;

  IF coach_shift <> NEW.shift THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Coach shift must match the cohort shift';
  END IF;
END$$

DELIMITER ;

DELIMITER $$
CREATE TRIGGER cohort_unit_BEFORE_INSERT
BEFORE INSERT ON cohort_unit
FOR EACH ROW
BEGIN
DECLARE professor_shift VARCHAR(10);
  DECLARE cohort_shift VARCHAR(10);

  IF NEW.professor_id IS NOT NULL THEN

    SELECT shift INTO professor_shift
      FROM professor
     WHERE professor_id = NEW.professor_id;
     
    SELECT shift INTO cohort_shift
      FROM cohort
     WHERE cohort_id = NEW.cohort_id;

    IF professor_shift <> cohort_shift THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Professor shift must match the cohort shift';
END IF;

  END IF;
END$$
DELIMITER ;

DELIMITER $$

DROP TRIGGER IF EXISTS cohort_BEFORE_UPDATE$$

CREATE TRIGGER cohort_BEFORE_UPDATE
BEFORE UPDATE ON cohort
FOR EACH ROW
BEGIN
  DECLARE coach_shift VARCHAR(10);

  IF NEW.coach_id IS NOT NULL THEN
    SELECT shift INTO coach_shift
      FROM coach
     WHERE coach_id = NEW.coach_id;

    IF coach_shift IS NULL OR coach_shift <> NEW.shift THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Coach shift must match the cohort shift';
    END IF;
  END IF;
END$$

DELIMITER ;

DELIMITER $$

DROP TRIGGER IF EXISTS cohort_unit_BEFORE_UPDATE$$

CREATE TRIGGER cohort_unit_BEFORE_UPDATE
BEFORE UPDATE ON cohort_unit
FOR EACH ROW
BEGIN
  DECLARE professor_shift VARCHAR(10);
  DECLARE cohort_shift VARCHAR(10);

  IF NEW.professor_id IS NOT NULL THEN

    SELECT shift INTO professor_shift
      FROM professor
     WHERE professor_id = NEW.professor_id;

    SELECT shift INTO cohort_shift
      FROM cohort
     WHERE cohort_id = NEW.cohort_id;

    IF professor_shift IS NULL OR cohort_shift IS NULL OR professor_shift <> cohort_shift THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Professor shift must match the cohort shift';
    END IF;

  END IF;
END$$

DELIMITER ;

DELIMITER $$

DROP TRIGGER IF EXISTS cohort_unit_BEFORE_INSERT_dates$$

CREATE TRIGGER cohort_unit_BEFORE_INSERT_dates
BEFORE INSERT ON cohort_unit
FOR EACH ROW
BEGIN
  DECLARE cohort_start DATE;
  DECLARE cohort_end DATE;

  IF NEW.cohort_id IS NOT NULL THEN
    SELECT start_date, end_date INTO cohort_start, cohort_end
      FROM cohort
     WHERE cohort_id = NEW.cohort_id;

    IF NEW.start_date < cohort_start OR NEW.end_date > cohort_end THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Unit dates must be within the cohort start and end dates';
    END IF;
  END IF;
END$$

DELIMITER ;

DELIMITER $$

DROP TRIGGER IF EXISTS cohort_unit_BEFORE_UPDATE_dates$$

CREATE TRIGGER cohort_unit_BEFORE_UPDATE_dates
BEFORE UPDATE ON cohort_unit
FOR EACH ROW
BEGIN
  DECLARE cohort_start DATE;
  DECLARE cohort_end DATE;

  IF NEW.cohort_id IS NOT NULL THEN
    SELECT start_date, end_date INTO cohort_start, cohort_end
      FROM cohort
     WHERE cohort_id = NEW.cohort_id;

    IF NEW.start_date < cohort_start OR NEW.end_date > cohort_end THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Unit dates must be within the cohort start and end dates';
    END IF;
  END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER attendance_AFTER_INSERT
AFTER INSERT ON attendance
FOR EACH ROW
BEGIN
  DECLARE unexcused INT;

  SELECT COUNT(*) INTO unexcused
    FROM attendance
   WHERE student_id = NEW.student_id
     AND status = 'Absent'
     AND excused_absence = 0;

  IF unexcused >= 5 THEN
    UPDATE enrollment
       SET final_result = 'Fail'
     WHERE student_id = NEW.student_id;
  END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER attendance_AFTER_UPDATE
AFTER UPDATE ON attendance
FOR EACH ROW
BEGIN
  DECLARE unexcused INT;

  SELECT COUNT(*) INTO unexcused
    FROM attendance
   WHERE student_id = NEW.student_id
     AND status = 'Absent'
     AND excused_absence = 0;

  IF unexcused >= 5 THEN
    UPDATE enrollment
       SET final_result = 'Fail'
     WHERE student_id = NEW.student_id;
  END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER tutoring_session_BEFORE_INSERT
BEFORE INSERT ON tutoring_session
FOR EACH ROW
BEGIN
  DECLARE unit_start DATE;
  DECLARE unit_end DATE;

  SELECT start_date, end_date INTO unit_start, unit_end
    FROM cohort_unit
   WHERE cohort_id = NEW.cohort_id
     AND unit_id = NEW.unit_id;

  IF DAYOFWEEK(NEW.session_date) <> 7 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Tutoring sessions must be on a Saturday';
  END IF;

  IF unit_start IS NULL OR unit_end IS NULL OR 
     NEW.session_date < unit_start OR 
     NEW.session_date > DATE_ADD(unit_end, INTERVAL 1 DAY) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Tutoring session must fall within the unit weeks';
  END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER tutoring_session_BEFORE_UPDATE
BEFORE UPDATE ON tutoring_session
FOR EACH ROW
BEGIN
  DECLARE unit_start DATE;
  DECLARE unit_end DATE;

  SELECT start_date, end_date INTO unit_start, unit_end
    FROM cohort_unit
   WHERE cohort_id = NEW.cohort_id
     AND unit_id = NEW.unit_id;

  IF DAYOFWEEK(NEW.session_date) <> 7 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Tutoring sessions must be on a Saturday';
  END IF;

  IF unit_start IS NULL OR unit_end IS NULL OR 
     NEW.session_date < unit_start OR 
     NEW.session_date > DATE_ADD(unit_end, INTERVAL 1 DAY) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Tutoring session must fall within the unit weeks';
  END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER assignment_BEFORE_INSERT
BEFORE INSERT ON assignment
FOR EACH ROW
BEGIN
  DECLARE cohort_start DATE;
  DECLARE cohort_end DATE;

  IF NEW.cohort_id IS NOT NULL THEN
    SELECT start_date, end_date INTO cohort_start, cohort_end
      FROM cohort
     WHERE cohort_id = NEW.cohort_id;

    IF cohort_start IS NULL OR cohort_end IS NULL OR
       NEW.assigned_date < cohort_start OR 
       NEW.due_date < cohort_start OR 
       NEW.assigned_date > cohort_end OR 
       NEW.due_date > cohort_end THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Assignment dates must be within the cohort dates';
    END IF;
  END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER assignment_BEFORE_UPDATE
BEFORE UPDATE ON assignment
FOR EACH ROW
BEGIN
  DECLARE cohort_start DATE;
  DECLARE cohort_end DATE;

  IF NEW.cohort_id IS NOT NULL THEN
    SELECT start_date, end_date INTO cohort_start, cohort_end
      FROM cohort
     WHERE cohort_id = NEW.cohort_id;

    IF cohort_start IS NULL OR cohort_end IS NULL OR
       NEW.assigned_date < cohort_start OR 
       NEW.due_date < cohort_start OR 
       NEW.assigned_date > cohort_end OR 
       NEW.due_date > cohort_end THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Assignment dates must be within the cohort dates';
    END IF;
  END IF;
END$$

DELIMITER ;

DELIMITER $$
CREATE TRIGGER application_BEFORE_UPDATE
BEFORE UPDATE ON application
FOR EACH ROW
BEGIN
DECLARE cap INT;
  DECLARE intake INT;

  IF NEW.approval_status = 'Approved' AND OLD.approval_status <> 'Approved' THEN

    SELECT max_students INTO cap
      FROM cohort
     WHERE cohort_id = NEW.cohort_id;

    SELECT COUNT(*) INTO intake
      FROM application
     WHERE cohort_id = NEW.cohort_id
       AND approval_status = 'Approved';

    IF intake >= cap THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cohort is full';
    END IF;

  END IF;
END$$
DELIMITER ;

DELIMITER $$

CREATE TRIGGER submission_BEFORE_INSERT_score
BEFORE INSERT ON submission
FOR EACH ROW
BEGIN
  DECLARE max_pts INT;

  IF NEW.assignment_id IS NOT NULL THEN
    SELECT max_points INTO max_pts
      FROM assignment
     WHERE assignment_id = NEW.assignment_id;

    IF max_pts IS NOT NULL AND NEW.score > max_pts THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Score cannot be greater than maximum points allowed';
    END IF;
  END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER submission_BEFORE_UPDATE_score
BEFORE UPDATE ON submission
FOR EACH ROW
BEGIN
  DECLARE max_pts INT;

  IF NEW.assignment_id IS NOT NULL THEN
    SELECT max_points INTO max_pts
      FROM assignment
     WHERE assignment_id = NEW.assignment_id;

    IF max_pts IS NOT NULL AND NEW.score > max_pts THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Score cannot be greater than maximum points allowed';
    END IF;
  END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER enrollment_BEFORE_INSERT
BEFORE INSERT ON enrollment
FOR EACH ROW
BEGIN
  DECLARE approved_count INT;

  IF NEW.student_id IS NOT NULL AND NEW.cohort_id IS NOT NULL THEN
    SELECT COUNT(*) INTO approved_count
      FROM application
     WHERE student_id = NEW.student_id
       AND cohort_id = NEW.cohort_id
       AND approval_status = 'Approved';

    IF approved_count = 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Student must have an approved application for this cohort';
    END IF;
  END IF;
END$$

DELIMITER ;

INSERT INTO cohort (coach_id, shift, start_date, end_date, max_students)
VALUES (20, 'Day', '2027-02-01', '2027-04-23', 50);

INSERT INTO cohort (coach_id, shift, start_date, end_date, max_students)
VALUES (20, 'Night', '2027-02-01', '2027-04-23', 50);

INSERT INTO submission (student_id, assignment_id, submitted_at, score)
VALUES
(103, 1, '2026-11-06 08:35:00', 54.00),
(104, 2, '2026-11-06 23:58:00', 65.00);

INSERT INTO submission (student_id, assignment_id, submitted_at, score)
VALUES
(103, 1, '2026-11-06 08:35:00', 60.00),
(104, 2, '2026-11-06 23:58:00', 58.00);

