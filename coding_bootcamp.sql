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
unit_id INT NOT NULL,
unit_name VARCHAR(60) NOT NULL,
sequence_no INT NOT NULL,
duration_weeks INT DEFAULT 2,
PRIMARY KEY (unit_id),
UNIQUE (unit_name), 
UNIQUE (sequence_no)
);

CREATE TABLE cohort (
cohort_id INT NOT NULL,
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
application_DATE DATE NOT NULL,
exam_score DECIMAL(5,2) NOT NULL,
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