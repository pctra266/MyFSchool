-- Dọn dẹp dữ liệu cũ (Tùy chọn: chỉ chạy nếu bạn muốn làm mới hoàn toàn)
-- DELETE FROM NewsAttachments; DELETE FROM News; DELETE FROM Transactions; ...

-- 1. Insert Users (Đã sửa tên cột và thêm EmailEnabled, PushEnabled, CreatedAt)
INSERT INTO Users (FullName, Email, PasswordHash, Role, FocusArea, EmailEnabled, PushEnabled, CreatedAt) VALUES
(N'Alice CrawlingOne', 'alice.student@email.com', '$2a$11$MLvO0pyA0xkpYQdJxwrgUu8A/DVgfnDNunBy0bkdQkguoI0vLjUQ.', 'Student', '10A1', 1, 1, GETDATE()),
(N'4nim0sity', 'dangcap@email.com', '$2a$11$MLvO0pyA0xkpYQdJxwrgUu8A/DVgfnDNunBy0bkdQkguoI0vLjUQ.', 'Student', 'Product design lead', 1, 1, GETDATE()),
(N'Mr. Anderson', 'anderson@school.edu', '$2a$11$MLvO0pyA0xkpYQdJxwrgUu8A/DVgfnDNunBy0bkdQkguoI0vLjUQ.', 'Teacher', 'Mathematics', 1, 1, GETDATE()),
(N'Ms. Curie', 'curie@school.edu', '$2a$11$MLvO0pyA0xkpYQdJxwrgUu8A/DVgfnDNunBy0bkdQkguoI0vLjUQ.', 'Teacher', 'Physics', 1, 1, GETDATE()),
(N'Mr. Shakespeare', 'shakespeare@school.edu', '$2a$11$MLvO0pyA0xkpYQdJxwrgUu8A/DVgfnDNunBy0bkdQkguoI0vLjUQ.', 'Teacher', 'Literature', 1, 1, GETDATE()),
(N'Mr. Bolt', 'bolt@school.edu', '$2a$11$MLvO0pyA0xkpYQdJxwrgUu8A/DVgfnDNunBy0bkdQkguoI0vLjUQ.', 'Teacher', 'Physical Education', 1, 1, GETDATE()),
(N'Ms. Rowling', 'rowling@school.edu', '$2a$11$MLvO0pyA0xkpYQdJxwrgUu8A/DVgfnDNunBy0bkdQkguoI0vLjUQ.', 'Teacher', 'English', 1, 1, GETDATE());

-- 2. Insert Classes
INSERT INTO Classes (Name) VALUES
(N'10A1'),
(N'10A2');

-- 3. Enroll Students to Classes (Giả sử ID của Alice là 1, 4nim0sity là 2)
INSERT INTO StudentClasses (StudentId, ClassId) VALUES
(1, 1),
(2, 1);

-- 4. Subjects
INSERT INTO Subjects (Name, TeacherId) VALUES
(N'Mathematics', 3),
(N'Physics', 4),
(N'Literature', 5),
(N'Physical Education', 6),
(N'English', 7);

-- 5. Academic Results
INSERT INTO AcademicResults (StudentId, SubjectId, Semester, AssessmentName, Score) VALUES
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

-- 6. Class Timetable
INSERT INTO Timetable (ClassId, SubjectId, TeacherId, Room, DayOfWeek, StartTime, EndTime) VALUES
(1, 1, 3, N'Room 101', 'Monday', '07:00:00', '08:30:00'),
(1, 2, 4, N'Lab 203', 'Monday', '08:45:00', '10:15:00'),
(1, 3, 5, N'Room 105', 'Monday', '10:30:00', '12:00:00'),
(1, 4, 6, N'Ground', 'Monday', '13:30:00', '15:00:00');

-- 7. Attendance
INSERT INTO Attendance (StudentId, AttendanceDate, Status) VALUES
(1, '2023-08-01', 'Present'), (1, '2023-08-02', 'Present'),
(1, '2023-08-03', 'Present'), (1, '2023-08-04', 'Present'),
(1, '2023-08-15', 'Late'),    (1, '2023-08-12', 'Absent');

-- 8. Leave requests
INSERT INTO LeaveRequests (StudentId, RequestDate, Reason, Status) VALUES
(1, '2023-08-12', N'Family matter and feeling slightly unwell.', 'Approved');

-- 9. Transactions
INSERT INTO Transactions (StudentId, Title, Amount, TransactionType, Status, TransactionDate) VALUES
(1, N'Tuition Fee - Term 1', 5000000.00, 'Debit', 'Paid', '2023-08-15'),
(1, N'Uniform Fee', 1200000.00, 'Debit', 'Paid', '2023-08-10'),
(1, N'Wallet Top-up', 10000000.00, 'Credit', 'Success', '2023-08-01');

-- 10. News
INSERT INTO News (Title, Description, Category, ImageUrl, CreatedAt) VALUES
(N'School Announcement', N'No detail content.', N'Announcement', 'https://picsum.photos/600/300?school', GETDATE());

-- 11. News Attachments
INSERT INTO NewsAttachments (NewsId, FileName, FileSize, FileUrl) VALUES
(1, N'Meeting_Agenda.pdf', N'2.5 MB', '/files/meeting_agenda.pdf'),
(1, N'Parent_Consent_Form.docx', N'1.2 MB', '/files/parent_consent_form.docx');

-- 12. Notes
-- Giáo viên Mathematics (Id 3) và Physics (Id 4) ghi chú cho Alice (Id 1)
INSERT INTO Notes (StudentId, TeacherId, Content, Type, CreatedAt) VALUES
(1, 3, N'Alice has been performing exceptionally well in Advanced Algebra. Keep it up!', 'Academic', DATEADD(day, -2, GETDATE())),
(1, 4, N'Needs to pay more attention during laboratory sessions. Slightly distracted.', 'Behavior', DATEADD(day, -5, GETDATE())),
(1, 3, N'Remember to bring the permission slip for the field trip next week. Also, check the math homework on page 42.', 'Personal', GETDATE());

-- 13. Meal Plans
INSERT INTO MealPlans (DayOfWeek, MainDish, SideDish, Soup) VALUES
('Monday', N'Grilled Chicken & Rice', N'Steamed Vegetables', N'Pumpkin Soup'),
('Tuesday', N'Spaghetti Bolognese', N'Garlic Bread', N'Minestrone'),
('Wednesday', N'Fish & Chips', N'Coleslaw', N'Corn Soup'),
('Thursday', N'Beef Stew', N'Mashed Potatoes', N'Mushroom Soup'),
('Friday', N'Pizza Margherita', N'Caesar Salad', N'Tomato Soup');