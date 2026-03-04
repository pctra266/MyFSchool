-- 1. Bảng Người dùng
CREATE TABLE Users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    full_name NVARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role NVARCHAR(50) NOT NULL CHECK (role IN (N'Student', N'Teacher', N'Admin', N'Parent')),
    focus_area NVARCHAR(100),
    push_enabled BIT DEFAULT 1, -- 1 là True
    email_enabled BIT DEFAULT 0, -- 0 là False
    created_at DATETIME DEFAULT GETDATE()
);

-- 2. Bảng Lớp học
CREATE TABLE Classes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(50) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT GETDATE()
);

-- 3. Bảng Liên kết Sinh viên - Lớp
CREATE TABLE StudentClasses (
    student_id INT NOT NULL,
    class_id INT NOT NULL,
    PRIMARY KEY (student_id, class_id),
    CONSTRAINT FK_Student FOREIGN KEY (student_id) REFERENCES Users(id) ON DELETE CASCADE,
    CONSTRAINT FK_Class FOREIGN KEY (class_id) REFERENCES Classes(id) ON DELETE CASCADE
);

-- 4. Bảng Môn học
CREATE TABLE Subjects (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    teacher_id INT NULL,
    CONSTRAINT FK_Subject_Teacher FOREIGN KEY (teacher_id) REFERENCES Users(id) ON DELETE SET NULL
);

-- 5. Bảng Kết quả học tập
CREATE TABLE AcademicResults (
    id INT IDENTITY(1,1) PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    semester INT NOT NULL CHECK (semester > 0),
    assessment_name NVARCHAR(100) NOT NULL,
    score DECIMAL(4, 2) NOT NULL CHECK (score >= 0 AND score <= 10),
    CONSTRAINT FK_Result_Student FOREIGN KEY (student_id) REFERENCES Users(id) ON DELETE CASCADE,
    CONSTRAINT FK_Result_Subject FOREIGN KEY (subject_id) REFERENCES Subjects(id) ON DELETE CASCADE
);

-- 6. Thời khóa biểu
CREATE TABLE Timetable (
    id INT IDENTITY(1,1) PRIMARY KEY,
    class_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NULL,
    room NVARCHAR(50) NOT NULL,
    day_of_week NVARCHAR(15) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    CONSTRAINT FK_Time_Class FOREIGN KEY (class_id) REFERENCES Classes(id) ON DELETE CASCADE,
    CONSTRAINT FK_Time_Subject FOREIGN KEY (subject_id) REFERENCES Subjects(id) ON DELETE CASCADE,
    CONSTRAINT FK_Time_Teacher FOREIGN KEY (teacher_id) REFERENCES Users(id) ON DELETE SET NULL
);

-- 7. Điểm danh
CREATE TABLE Attendance (
    id INT IDENTITY(1,1) PRIMARY KEY,
    student_id INT NOT NULL,
    attendance_date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    status NVARCHAR(20) NOT NULL CHECK (status IN (N'Present', N'Absent', N'Late', N'Excused')),
    CONSTRAINT FK_Att_Student FOREIGN KEY (student_id) REFERENCES Users(id) ON DELETE CASCADE,
    CONSTRAINT UQ_Student_Date UNIQUE(student_id, attendance_date)
);

-- 8. Đơn xin nghỉ phép
CREATE TABLE LeaveRequests (
    id INT IDENTITY(1,1) PRIMARY KEY,
    student_id INT NOT NULL,
    request_date DATE NOT NULL,
    reason NVARCHAR(MAX) NOT NULL, -- Dùng NVARCHAR(MAX) cho nội dung dài
    status NVARCHAR(20) DEFAULT N'Pending' CHECK (status IN (N'Pending', N'Approved', N'Rejected')),
    document_url VARCHAR(255),
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Leave_Student FOREIGN KEY (student_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- 9. Giao dịch tài chính
CREATE TABLE Transactions (
    id INT IDENTITY(1,1) PRIMARY KEY,
    student_id INT NOT NULL,
    title NVARCHAR(150) NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('Credit', 'Debit')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('Paid', 'Success', 'Pending', 'Failed')),
    transaction_date DATE NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Trans_Student FOREIGN KEY (student_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- 10. Tin tức
CREATE TABLE News (
    id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX) NOT NULL,
    category NVARCHAR(50) NOT NULL,
    image_url VARCHAR(255),
    created_at DATETIME DEFAULT GETDATE()
);

-- 11. Đính kèm tin tức
CREATE TABLE NewsAttachments (
    id INT IDENTITY(1,1) PRIMARY KEY,
    news_id INT NOT NULL,
    file_name NVARCHAR(255) NOT NULL,
    file_size NVARCHAR(50) NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    CONSTRAINT FK_Attach_News FOREIGN KEY (news_id) REFERENCES News(id) ON DELETE CASCADE
);