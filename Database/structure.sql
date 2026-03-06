-- 1. Bảng Users (Đã sửa tên cột và thêm các cột thiếu)
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(255),
    Email NVARCHAR(255),
    PasswordHash NVARCHAR(MAX),
    Role NVARCHAR(50),
    FocusArea NVARCHAR(255),
    EmailEnabled BIT DEFAULT 1,     -- Cột EF yêu cầu
    PushEnabled BIT DEFAULT 1,      -- Cột EF yêu cầu
    CreatedAt DATETIME DEFAULT GETDATE() -- Cột EF yêu cầu
);

-- 2. Bảng Classes
CREATE TABLE Classes (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100)
);

-- 3. Bảng StudentClasses
CREATE TABLE StudentClasses (
    StudentId INT,
    ClassId INT,
    PRIMARY KEY (StudentId, ClassId),
    FOREIGN KEY (StudentId) REFERENCES Users(Id),
    FOREIGN KEY (ClassId) REFERENCES Classes(Id)
);

-- 4. Bảng Subjects
CREATE TABLE Subjects (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100),
    TeacherId INT,
    FOREIGN KEY (TeacherId) REFERENCES Users(Id)
);

-- 5. Bảng AcademicResults
CREATE TABLE AcademicResults (
    Id INT PRIMARY KEY IDENTITY(1,1),
    StudentId INT,
    SubjectId INT,
    Semester INT,
    AssessmentName NVARCHAR(100),
    Score DECIMAL(4, 2),
    FOREIGN KEY (StudentId) REFERENCES Users(Id),
    FOREIGN KEY (SubjectId) REFERENCES Subjects(Id)
);

-- 6. Bảng Timetable
CREATE TABLE Timetable (
    Id INT PRIMARY KEY IDENTITY(1,1),
    ClassId INT,
    SubjectId INT,
    TeacherId INT,
    Room NVARCHAR(50),
    DayOfWeek NVARCHAR(20),
    StartTime TIME,
    EndTime TIME,
    FOREIGN KEY (ClassId) REFERENCES Classes(Id),
    FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    FOREIGN KEY (TeacherId) REFERENCES Users(Id)
);

-- 7. Bảng Attendance
CREATE TABLE Attendance (
    Id INT PRIMARY KEY IDENTITY(1,1),
    StudentId INT,
    AttendanceDate DATE,
    Status NVARCHAR(50),
    FOREIGN KEY (StudentId) REFERENCES Users(Id)
);

-- 8. Bảng LeaveRequests
CREATE TABLE LeaveRequests (
    Id INT PRIMARY KEY IDENTITY(1,1),
    StudentId INT,
    RequestDate DATE,
    Reason NVARCHAR(MAX),
    Status NVARCHAR(50),
    FOREIGN KEY (StudentId) REFERENCES Users(Id)
);

-- 9. Bảng Transactions
CREATE TABLE Transactions (
    Id INT PRIMARY KEY IDENTITY(1,1),
    StudentId INT,
    Title NVARCHAR(255),
    Amount DECIMAL(18, 2),
    TransactionType NVARCHAR(50),
    Status NVARCHAR(50),
    TransactionDate DATETIME,
    FOREIGN KEY (StudentId) REFERENCES Users(Id)
);

-- 10. Bảng News
CREATE TABLE News (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(255),
    Description NVARCHAR(MAX),
    Category NVARCHAR(100),
    ImageUrl NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- 11. Bảng NewsAttachments
CREATE TABLE NewsAttachments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    NewsId INT,
    FileName NVARCHAR(255),
    FileSize NVARCHAR(50),
    FileUrl NVARCHAR(MAX),
    FOREIGN KEY (NewsId) REFERENCES News(Id)
);

