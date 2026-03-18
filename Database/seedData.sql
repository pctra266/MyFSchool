-- ============================================================
-- SEED DATA - MyFSchool
-- Thời điểm tham chiếu: Tháng 3/2026 (Học kỳ 2, năm học 2025-2026)
-- ============================================================

-- 1. Insert Users
-- Password hash tương ứng với chuỗi "Password@123"
INSERT INTO Users (FullName, Email, PasswordHash, FocusArea, DateOfBirth, Gender, Address, PhoneNumber, ParentName, EmailEnabled, PushEnabled, CreatedAt) VALUES
-- Students
(N'Nguyễn Thị Alice',     'trapche186790@gmail.com',      '$2a$11$MLvO0pyA0xkpYQdJxwrgUu8A/DVgfnDNunBy0bkdQkguoI0vLjUQ.', N'10A1',              '2009-08-15', N'Nữ',  N'45 Đường Lê Lợi, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh', '0947852588', N'Nguyễn Văn Cường',   1, 1, '2025-08-20 08:00:00'),
(N'Trần Minh Khoa',       'dangcap@email.com',             '$2a$11$MLvO0pyA0xkpYQdJxwrgUu8A/DVgfnDNunBy0bkdQkguoI0vLjUQ.', N'10A1',              '2009-05-10', N'Nam', N'12 Đường Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh', '0987654321', N'Trần Văn Dũng',      1, 1, '2025-08-20 08:05:00'),
-- Teachers
(N'Thầy Nguyễn Văn An',   'anderson@school.edu',           '$2a$11$MLvO0pyA0xkpYQdJxwrgUu8A/DVgfnDNunBy0bkdQkguoI0vLjUQ.', N'Toán học',          '1982-01-15', N'Nam', N'78 Đường Đinh Tiên Hoàng, Phường Đakao, Quận 1, TP. HCM',       '0912345678', NULL,                  1, 1, '2025-07-15 09:00:00'),
(N'Cô Trần Thị Bích',     'curie@school.edu',              '$2a$11$MLvO0pyA0xkpYQdJxwrgUu8A/DVgfnDNunBy0bkdQkguoI0vLjUQ.', N'Vật lý',            '1987-02-20', N'Nữ',  N'33 Đường Hai Bà Trưng, Phường Đakao, Quận 1, TP. HCM',          '0923456789', NULL,                  1, 1, '2025-07-15 09:05:00'),
(N'Thầy Lê Văn Chính',    'shakespeare@school.edu',        '$2a$11$MLvO0pyA0xkpYQdJxwrgUu8A/DVgfnDNunBy0bkdQkguoI0vLjUQ.', N'Ngữ văn',           '1978-03-10', N'Nam', N'99 Đường Pasteur, Phường 6, Quận 3, TP. HCM',                    '0934567890', NULL,                  1, 1, '2025-07-15 09:10:00'),
(N'Thầy Phạm Quốc Đạt',   'bolt@school.edu',               '$2a$11$MLvO0pyA0xkpYQdJxwrgUu8A/DVgfnDNunBy0bkdQkguoI0vLjUQ.', N'Thể dục',           '1991-04-25', N'Nam', N'15 Đường Võ Văn Tần, Phường 6, Quận 3, TP. HCM',                '0945678901', NULL,                  1, 1, '2025-07-15 09:15:00'),
(N'Cô Hoàng Thị Lan',     'rowling@school.edu',            '$2a$11$MLvO0pyA0xkpYQdJxwrgUu8A/DVgfnDNunBy0bkdQkguoI0vLjUQ.', N'Tiếng Anh',         '1985-05-05', N'Nữ',  N'21 Đường Nguyễn Đình Chiểu, Phường 3, Quận 3, TP. HCM',         '0956789012', NULL,                  1, 1, '2025-07-15 09:20:00');

-- 1A. Roles
INSERT INTO Roles (Name) VALUES
('Student'),
('Teacher'),
('Admin');

-- 1B. UserRoles
INSERT INTO UserRoles (UserId, RoleId) VALUES
(1, 1), -- Alice       → Student
(2, 1), -- Minh Khoa  → Student
(3, 2), -- Thầy An    → Teacher
(4, 2), -- Cô Bích    → Teacher
(5, 2), -- Thầy Chính → Teacher
(6, 2), -- Thầy Đạt   → Teacher
(7, 2); -- Cô Lan     → Teacher

-- 2. Classes
INSERT INTO Classes (Name) VALUES
(N'10A1'),
(N'10A2');

-- 3. StudentClasses
INSERT INTO StudentClasses (StudentId, ClassId) VALUES
(1, 1), -- Alice     → 10A1
(2, 1); -- Minh Khoa → 10A1

-- 4. Subjects
INSERT INTO Subjects (Name, TeacherId) VALUES
(N'Toán học',    3), -- Thầy An
(N'Vật lý',      4), -- Cô Bích
(N'Ngữ văn',     5), -- Thầy Chính
(N'Thể dục',     6), -- Thầy Đạt
(N'Tiếng Anh',   7); -- Cô Lan

-- 5. Academic Results (Học kỳ 1: Sep–Dec 2025 | Học kỳ 2: Jan–Jun 2026)
-- Alice (Id=1)
INSERT INTO AcademicResults (StudentId, SubjectId, Semester, AssessmentName, Score) VALUES
-- Học kỳ 1
(1, 1, 1, N'Kiểm tra 15 phút', 9.0),
(1, 1, 1, N'Kiểm tra giữa kỳ', 9.5),
(1, 1, 1, N'Thi cuối kỳ',      9.8),
(1, 2, 1, N'Kiểm tra 15 phút', 8.5),
(1, 2, 1, N'Kiểm tra giữa kỳ', 9.0),
(1, 2, 1, N'Thi cuối kỳ',      8.5),
(1, 3, 1, N'Kiểm tra 15 phút', 8.0),
(1, 3, 1, N'Kiểm tra giữa kỳ', 8.5),
(1, 3, 1, N'Thi cuối kỳ',      9.0),
(1, 5, 1, N'Kiểm tra 15 phút', 9.5),
(1, 5, 1, N'Kiểm tra giữa kỳ', 9.0),
(1, 5, 1, N'Thi cuối kỳ',      9.2),
-- Học kỳ 2 (đang diễn ra - đã có điểm 15 phút và giữa kỳ)
(1, 1, 2, N'Kiểm tra 15 phút', 9.5),
(1, 1, 2, N'Kiểm tra giữa kỳ', 10.0),
(1, 2, 2, N'Kiểm tra 15 phút', 9.0),
(1, 2, 2, N'Kiểm tra giữa kỳ', 8.5),
(1, 3, 2, N'Kiểm tra 15 phút', 8.5),
(1, 5, 2, N'Kiểm tra 15 phút', 10.0);

-- 6. Timetable (Thời khóa biểu lớp 10A1)
INSERT INTO Timetable (ClassId, SubjectId, TeacherId, Room, DayOfWeek, StartTime, EndTime) VALUES
(1, 1, 3, N'Phòng 101',  'Monday',    '07:00:00', '08:30:00'),
(1, 2, 4, N'Phòng LAB',  'Monday',    '08:45:00', '10:15:00'),
(1, 3, 5, N'Phòng 105',  'Monday',    '10:30:00', '12:00:00'),
(1, 4, 6, N'Sân trường', 'Tuesday',   '07:00:00', '08:30:00'),
(1, 5, 7, N'Phòng 201',  'Tuesday',   '08:45:00', '10:15:00'),
(1, 1, 3, N'Phòng 101',  'Wednesday', '07:00:00', '08:30:00'),
(1, 2, 4, N'Phòng LAB',  'Wednesday', '10:30:00', '12:00:00'),
(1, 5, 7, N'Phòng 201',  'Thursday',  '07:00:00', '08:30:00'),
(1, 3, 5, N'Phòng 105',  'Thursday',  '08:45:00', '10:15:00'),
(1, 4, 6, N'Sân trường', 'Friday',    '10:30:00', '12:00:00');

-- 7. Attendance (Tháng 3/2026 - HK2)
INSERT INTO Attendance (StudentId, AttendanceDate, Status) VALUES
-- Tuần 1 tháng 3
(1, '2026-03-02', 'Present'),
(1, '2026-03-03', 'Present'),
(1, '2026-03-04', 'Present'),
(1, '2026-03-05', 'Present'),
(1, '2026-03-06', 'Present'),
-- Tuần 2 tháng 3
(1, '2026-03-09', 'Present'),
(1, '2026-03-10', 'Present'),
(1, '2026-03-11', 'Late'),
(1, '2026-03-12', 'Present'),
-- Tháng 2/2026
(1, '2026-02-17', 'Present'),
(1, '2026-02-18', 'Present'),
(1, '2026-02-19', 'Present'),
(1, '2026-02-20', 'Present'),
(1, '2026-02-21', 'Absent'),
(1, '2026-02-24', 'Present'),
(1, '2026-02-25', 'Present'),
(1, '2026-02-26', 'Present'),
(1, '2026-02-27', 'Present'),
(1, '2026-02-28', 'Present'),
-- Tháng 1/2026
(1, '2026-01-05', 'Present'),
(1, '2026-01-06', 'Present'),
(1, '2026-01-07', 'Present'),
(1, '2026-01-08', 'Present'),
(1, '2026-01-09', 'Present');

-- 8. Leave Requests
INSERT INTO LeaveRequests (StudentId, RequestDate, Reason, Status) VALUES
(1, '2026-02-21', N'Ốm sốt, có giấy xác nhận của bác sĩ.',         'Approved'),
(1, '2026-01-20', N'Việc gia đình quan trọng, xin phép nghỉ 1 ngày.', 'Approved'),
(1, '2026-03-11', N'Đi muộn do kẹt xe buổi sáng.',                   'Approved');

-- 9. Transactions (Năm học 2025-2026)
INSERT INTO Transactions (StudentId, Title, Amount, TransactionType, Status, TransactionDate) VALUES
(1, N'Nạp ví - Tháng 9/2025',          10000000.00, 'Credit', 'Success', '2025-09-01 09:00:00'),
(1, N'Học phí - Học kỳ 1 (2025-2026)',  5500000.00, 'Debit',  'Paid',    '2025-09-05 10:00:00'),
(1, N'Phí đồng phục',                   1200000.00, 'Debit',  'Paid',    '2025-09-10 11:00:00'),
(1, N'Phí sách giáo khoa',               850000.00, 'Debit',  'Paid',    '2025-09-12 14:00:00'),
(1, N'Nạp ví - Tháng 1/2026',          10000000.00, 'Credit', 'Success', '2026-01-06 08:30:00'),
(1, N'Học phí - Học kỳ 2 (2025-2026)',  5500000.00, 'Debit',  'Paid',    '2026-01-08 10:00:00'),
(1, N'Phí hoạt động ngoại khóa HK2',    500000.00, 'Debit',  'Paid',    '2026-01-10 10:30:00'),
(1, N'Phí bảo hiểm y tế học sinh',      650000.00, 'Debit',  'Paid',    '2026-01-15 09:00:00');

-- 10. News
INSERT INTO News (Title, Description, Category, ImageUrl, CreatedAt) VALUES
(N'Thông báo lịch thi học kỳ 2 năm học 2025-2026',
 N'Nhà trường trân trọng thông báo lịch thi học kỳ 2 năm học 2025-2026 sẽ diễn ra từ ngày 20/05/2026 đến 30/05/2026. Học sinh vui lòng xem chi tiết lịch thi theo lớp được đính kèm.',
 N'Announcement', 'https://picsum.photos/600/300?school1', '2026-03-10 08:00:00'),
(N'Cuộc thi Toán học Quốc tế 2026',
 N'Trường thông báo về cuộc thi Toán học Quốc tế dành cho học sinh lớp 10-12 sẽ được tổ chức vào tháng 4/2026. Học sinh quan tâm vui lòng đăng ký trước ngày 25/03/2026.',
 N'Event',        'https://picsum.photos/600/300?math',    '2026-03-08 08:00:00'),
(N'Ngày hội thể thao trường 2026',
 N'Ngày hội thể thao thường niên sẽ được tổ chức vào ngày 22/03/2026. Học sinh tham gia đầy đủ sẽ được tính điểm rèn luyện.',
 N'Event',        'https://picsum.photos/600/300?sport',   '2026-03-05 09:00:00'),
(N'Kết quả thi giữa kỳ 2 - Bảng xếp hạng',
 N'Nhà trường công bố bảng xếp hạng kết quả thi giữa kỳ 2. Chúc mừng những học sinh đạt thành tích xuất sắc!',
 N'Academic',     'https://picsum.photos/600/300?result',  '2026-03-01 10:00:00');

-- 11. News Attachments
INSERT INTO NewsAttachments (NewsId, FileName, FileSize, FileUrl) VALUES
(1, N'LichThi_HK2_2025-2026.pdf',       N'1.8 MB', '/files/lich_thi_hk2.pdf'),
(1, N'QuyDinhPhongThi.pdf',              N'0.9 MB', '/files/quy_dinh_phong_thi.pdf'),
(2, N'TheTle_ThiToan2026.pdf',           N'1.2 MB', '/files/the_le_thi_toan.pdf'),
(3, N'LichTranh_NgayHoiTheThao.pdf',    N'0.7 MB', '/files/lich_tranh_the_thao.pdf');

-- 12. Notes (Giáo viên ghi chú cho Alice)
INSERT INTO Notes (StudentId, TeacherId, Content, Type, CreatedAt) VALUES
(1, 3, N'Alice đã đạt điểm tuyệt đối trong bài kiểm tra giữa kỳ môn Toán. Tiếp tục phát huy!',        'Academic',  '2026-03-01 10:00:00'),
(1, 4, N'Cần chú ý hơn trong giờ thực hành vật lý. Còn lơ đãng và thiếu tập trung một chút.',          'Behavior',  '2026-02-28 14:00:00'),
(1, 7, N'Alice có khả năng ngôn ngữ tiếng Anh rất tốt. Nên khuyến khích tham gia câu lạc bộ English.', 'Academic',  '2026-02-25 11:00:00'),
(1, 5, N'Nhắc nhở mang bài tập về nhà đã chấm về nhà ký xác nhận phụ huynh.',                           'Personal',  '2026-03-05 09:30:00'),
(1, 3, N'Alice được chọn tham gia đội tuyển Toán của trường dự thi cấp thành phố tháng 4/2026.',        'Academic',  '2026-03-10 08:00:00');

-- 13. Meal Plans (Tuần hiện tại, tháng 3/2026)
INSERT INTO MealPlans (DayOfWeek, MainDish, SideDish, Soup) VALUES
('Monday',    N'Cơm gà chiên giòn',           N'Rau cải luộc & dưa leo',  N'Canh bí đỏ hầm xương'),
('Tuesday',   N'Bún bò Huế',                  N'Rau sống & giá đỗ',       N'Canh chua cá lóc'),
('Wednesday', N'Cơm sườn nướng mật ong',      N'Đậu bắp xào tỏi',         N'Canh khổ qua nhồi thịt'),
('Thursday',  N'Mì Ý sốt bò bằm',            N'Bánh mì & salad',          N'Súp khoai tây kem'),
('Friday',    N'Cơm chiên dương châu & trứng', N'Kim chi & dưa chua',      N'Canh rau ngót thịt bằm');

-- 14. Health Records (Alice - cập nhật đến đầu học kỳ 2)
INSERT INTO HealthRecords (StudentId, RecordDate, Height, Weight, BMI, BloodType, Allergies, MedicalNotes) VALUES
(1, '2025-09-01', 161.0, 51.5, 19.88, 'O+', N'Không',          N'Sức khỏe tốt, không có bệnh lý nền. Đã tiêm đầy đủ các mũi vắc xin theo chương trình y tế học đường.'),
(1, '2026-01-10', 162.5, 52.8, 19.99, 'O+', N'Dị ứng tôm nhẹ', N'Khám định kỳ đầu học kỳ 2. Sức khỏe ổn định. Cần chú ý tránh các món ăn có tôm trong thực đơn bữa trưa.');

-- 15. Notifications (Gần đây nhất đứng đầu)
INSERT INTO Notifications (UserId, Title, Description, IsRead, CreatedAt) VALUES
(1, N' Lịch thi cuối kỳ đã được công bố',
   N'Lịch thi học kỳ 2 đã được đăng tải. Kỳ thi diễn ra từ ngày 20/05 đến 30/05/2026. Vui lòng xem chi tiết tại mục Thông báo.',
   0, '2026-03-10 08:30:00'),
(1, N' Chúc mừng kết quả giữa kỳ xuất sắc!',
   N'Em đã đạt điểm 10 môn Toán trong kỳ thi giữa học kỳ 2. Nhà trường và giáo viên chúc mừng thành tích xuất sắc của em!',
   0, '2026-03-01 09:00:00'),
(1, N' Ngày hội thể thao 22/03/2026',
   N'Ngày hội thể thao thường niên sẽ diễn ra vào Chủ nhật 22/03/2026. Học sinh tham gia mặc đồng phục thể dục và có mặt tại sân trường lúc 7h00.',
   0, '2026-03-05 10:00:00'),
(1, N' Xác nhận thanh toán học phí HK2',
   N'Nhà trường đã nhận được khoản thanh toán học phí học kỳ 2 (5.500.000 VNĐ) vào ngày 08/01/2026. Cảm ơn quý phụ huynh!',
   1, '2026-01-08 10:30:00'),
(1, N' Nhắc nhở: Xin phép nghỉ cần nộp giấy bác sĩ',
   N'Liên quan đến ngày nghỉ 21/02/2026, vui lòng nộp giấy xác nhận của bác sĩ cho giáo viên chủ nhiệm trước ngày 28/02/2026.',
   1, '2026-02-22 08:00:00'),
(1, N' Đội tuyển Toán cấp thành phố',
   N'Em Alice đã được chọn vào đội tuyển Toán của trường, dự thi cấp thành phố vào tháng 4/2026. Lịch tập luyện sẽ được thông báo sau.',
   0, '2026-03-10 08:00:00');
