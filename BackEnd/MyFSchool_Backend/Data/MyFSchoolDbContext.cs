using Microsoft.EntityFrameworkCore;
using MyFSchool_Backend.Models;

namespace MyFSchool_Backend.Data;

public class MyFSchoolDbContext : DbContext
{
    public MyFSchoolDbContext(DbContextOptions<MyFSchoolDbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users { get; set; }
    public DbSet<Class> Classes { get; set; }
    public DbSet<StudentClass> StudentClasses { get; set; }
    public DbSet<Subject> Subjects { get; set; }
    public DbSet<AcademicResult> AcademicResults { get; set; }
    public DbSet<Timetable> Timetable { get; set; }
    public DbSet<Attendance> Attendance { get; set; }
    public DbSet<LeaveRequest> LeaveRequests { get; set; }
    public DbSet<Transaction> Transactions { get; set; }
    public DbSet<News> News { get; set; }
    public DbSet<NewsAttachment> NewsAttachments { get; set; }
    public DbSet<Note> Notes { get; set; }
    public DbSet<MealPlan> MealPlans { get; set; }
    public DbSet<HealthRecord> HealthRecords { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure Many-to-Many Join Table for StudentClasses
        modelBuilder.Entity<StudentClass>()
            .HasKey(sc => new { sc.StudentId, sc.ClassId });

        modelBuilder.Entity<StudentClass>()
            .HasOne(sc => sc.Student)
            .WithMany(s => s.StudentClasses)
            .HasForeignKey(sc => sc.StudentId);

        modelBuilder.Entity<StudentClass>()
            .HasOne(sc => sc.Class)
            .WithMany(c => c.StudentClasses)
            .HasForeignKey(sc => sc.ClassId);

        // Configure One-to-Many: User (Teacher) -> Subjects
        modelBuilder.Entity<Subject>()
            .HasOne(s => s.Teacher)
            .WithMany(u => u.TaughtSubjects)
            .HasForeignKey(s => s.TeacherId)
            .OnDelete(DeleteBehavior.SetNull);

        // Configure One-to-Many: User (Student) -> AcademicResults
        modelBuilder.Entity<AcademicResult>()
            .HasOne(ar => ar.Student)
            .WithMany(u => u.AcademicResults)
            .HasForeignKey(ar => ar.StudentId);

        // Configure One-to-Many: Subject -> AcademicResults
        modelBuilder.Entity<AcademicResult>()
            .HasOne(ar => ar.Subject)
            .WithMany(s => s.AcademicResults)
            .HasForeignKey(ar => ar.SubjectId);

        // Configure Timetable Relationships
        modelBuilder.Entity<Timetable>()
            .HasOne(t => t.Class)
            .WithMany(c => c.Timetables)
            .HasForeignKey(t => t.ClassId);

        modelBuilder.Entity<Timetable>()
            .HasOne(t => t.Subject)
            .WithMany(s => s.Timetables)
            .HasForeignKey(t => t.SubjectId);

        modelBuilder.Entity<Timetable>()
            .HasOne(t => t.Teacher)
            .WithMany()
            .HasForeignKey(t => t.TeacherId)
            .OnDelete(DeleteBehavior.SetNull);

        // Configure User (Student) -> Attendance
        modelBuilder.Entity<Attendance>()
            .HasOne(a => a.Student)
            .WithMany(u => u.Attendances)
            .HasForeignKey(a => a.StudentId);

        // Configure User (Student) -> LeaveRequests
        modelBuilder.Entity<LeaveRequest>()
            .HasOne(lr => lr.Student)
            .WithMany(u => u.LeaveRequests)
            .HasForeignKey(lr => lr.StudentId);

        // Configure User (Student) -> Transactions
        modelBuilder.Entity<Transaction>()
            .HasOne(tr => tr.Student)
            .WithMany(u => u.Transactions)
            .HasForeignKey(tr => tr.StudentId);

        // Configure News -> NewsAttachments
        modelBuilder.Entity<NewsAttachment>()
            .HasOne(na => na.News)
            .WithMany(n => n.Attachments)
            .HasForeignKey(na => na.NewsId);

        // Configure Note -> Users
        modelBuilder.Entity<Note>()
            .HasOne(n => n.Student)
            .WithMany(u => u.Notes)
            .HasForeignKey(n => n.StudentId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Note>()
            .HasOne(n => n.Teacher)
            .WithMany()
            .HasForeignKey(n => n.TeacherId)
            .OnDelete(DeleteBehavior.SetNull);

        modelBuilder.Entity<AcademicResult>()
            .Property(ar => ar.Score)
            .HasColumnType("decimal(4,2)");

        modelBuilder.Entity<Transaction>()
            .Property(t => t.Amount)
            .HasColumnType("decimal(15,2)");
        modelBuilder.Entity<Transaction>()
            .Property(t => t.TransactionDate)
            .HasColumnType("date");

        modelBuilder.Entity<Attendance>()
            .Property(a => a.AttendanceDate)
            .HasColumnType("date")
            .HasDefaultValueSql("CAST(GETDATE() AS DATE)");
        modelBuilder.Entity<Attendance>()
            .HasIndex(a => new { a.StudentId, a.AttendanceDate })
            .IsUnique();
        modelBuilder.Entity<Class>()
            .HasIndex(c => c.Name)
            .IsUnique();
    }
}
