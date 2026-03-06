using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyFSchool_Backend.Models
{
    public class HealthRecord
    {
        [Key]
        public int Id { get; set; }

        public int StudentId { get; set; }

        [Column(TypeName = "date")]
        public DateTime RecordDate { get; set; }

        [Column(TypeName = "decimal(5, 2)")]
        public decimal Height { get; set; }

        [Column(TypeName = "decimal(5, 2)")]
        public decimal Weight { get; set; }

        [Column(TypeName = "decimal(4, 2)")]
        public decimal BMI { get; set; }

        public string BloodType { get; set; }

        public string Allergies { get; set; }

        public string MedicalNotes { get; set; }

        // Navigation property
        [ForeignKey("StudentId")]
        public User Student { get; set; }
    }
}
