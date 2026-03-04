-- 1. Insert Users (Bỏ id để IDENTITY tự tăng, thêm N trước chuỗi tiếng Việt/Unicode)
INSERT INTO Users (full_name, email, role, focus_area) VALUES
(N'Alice CrawlingOne', 'alice.student@email.com', 'Student', '10A1'),
(N'4nim0sity', 'dangcap@email.com', 'Student', 'Product design lead'),
(N'Mr. Anderson', 'anderson@school.edu', 'Teacher', 'Mathematics'),
(N'Ms. Curie', 'curie@school.edu', 'Teacher', 'Physics'),
(N'Mr. Shakespeare', 'shakespeare@school.edu', 'Teacher', 'Literature'),
(N'Mr. Bolt', 'bolt@school.edu', 'Teacher', 'Physical Education'),
(N'Ms. Rowling', 'rowling@school.edu', 'Teacher', 'English');

-- 2. Insert Classes
INSERT INTO Classes (name) VALUES
(N'10A1'),
(N'10A2');

-- 3. Enroll Students to Classes (Giả sử ID tự tăng từ 1)
INSERT INTO StudentClasses (student_id, class_id) VALUES
(1, 1),
(2, 1);

-- 4. Subjects
INSERT INTO Subjects (name, teacher_id) VALUES
(N'Mathematics', 3),
(N'Physics', 4),
(N'Literature', 5),
(N'Physical Education', 6),
(N'English', 7);

-- 5. Academic Results (Lưu ý: score dùng dấu chấm thập phân)
INSERT INTO AcademicResults (student_id, subject_id, semester, assessment_name, score) VALUES
(1, 1, 1, N'15-min Test', 9.0),
(1, 1, 1, N'Mid-term', 9.5),
(1, 1, 1, N'Final', 10.0),
(1, 2, 1, N'15-min Test', 8.5),
(1, 2, 1, N'Mid-term', 9.0),
(1, 2, 1, N'Final', 8.5),
(1, 3, 1, N'15-min Test', 8.0),
(1, 3, 1, N'Mid-term', 8.5),
(1, 3, 1, N'Final', 9.0),
(1, 5, 1, N'15-min Test', 9.5),
(1, 5, 1, N'Mid-term', 9.0),
(1, 5, 1, N'Final', 8.5);

-- 6. Class Timetable (MSSQL dùng định dạng 'HH:MM:SS')
INSERT INTO Timetable (class_id, subject_id, teacher_id, room, day_of_week, start_time, end_time) VALUES
(1, 1, 3, N'Room 101', 'Monday', '07:00:00', '08:30:00'),
(1, 2, 4, N'Lab 203', 'Monday', '08:45:00', '10:15:00'),
(1, 3, 5, N'Room 105', 'Monday', '10:30:00', '12:00:00'),
(1, 4, 6, N'Ground', 'Monday', '13:30:00', '15:00:00');

-- 7. Attendance (Sửa tên cột 'date' thành 'attendance_date' như script trước đã tạo)
INSERT INTO Attendance (student_id, attendance_date, status) VALUES
(1, '2023-08-01', 'Present'), (1, '2023-08-02', 'Present'),
(1, '2023-08-03', 'Present'), (1, '2023-08-04', 'Present'),
(1, '2023-08-15', 'Late'),    (1, '2023-08-12', 'Absent');

-- 8. Leave requests
INSERT INTO LeaveRequests (student_id, request_date, reason, status) VALUES
(1, '2023-08-12', N'Family matter and feeling slightly unwell.', 'Approved');

-- 9. Transactions
INSERT INTO Transactions (student_id, title, amount, transaction_type, status, transaction_date) VALUES
(1, N'Tuition Fee - Term 1', 5000000.00, 'Debit', 'Paid', '2023-08-15'),
(1, N'Uniform Fee', 1200000.00, 'Debit', 'Paid', '2023-08-10'),
(1, N'Wallet Top-up', 10000000.00, 'Credit', 'Success', '2023-08-01');

-- 10. News
INSERT INTO News (title, description, category, image_url, created_at) VALUES
(N'School Announcement', N'No detail content.', N'Announcement', 'https://picsum.photos/600/300?school', '2023-08-20 10:00:00');

-- 11. News Attachments
INSERT INTO NewsAttachments (news_id, file_name, file_size, file_url) VALUES
(1, N'Meeting_Agenda.pdf', N'2.5 MB', '/files/meeting_agenda.pdf'),
(1, N'Parent_Consent_Form.docx', N'1.2 MB', '/files/parent_consent_form.docx');