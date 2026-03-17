using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Infrastructure.Persistence.Configurations;

public class SpecialDayConfiguration : IEntityTypeConfiguration<SpecialDay>
{
    public void Configure(EntityTypeBuilder<SpecialDay> builder)
    {
        builder.ToTable("SpecialDays");

        builder.HasKey(s => s.Id);

        builder.Property(s => s.Name)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(s => s.Date)
            .IsRequired();

        builder.Property(s => s.Description)
            .IsRequired()
            .HasMaxLength(1000); // Varsayılan bir uzunluk sınırı, ihtiyaca göre artırılabilir
    }
}
