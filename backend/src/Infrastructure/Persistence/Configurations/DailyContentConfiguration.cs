using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Infrastructure.Persistence.Configurations;

public class DailyContentConfiguration : IEntityTypeConfiguration<DailyContent>
{
    public void Configure(EntityTypeBuilder<DailyContent> builder)
    {
        builder.ToTable("DailyContents");

        builder.HasKey(d => d.Id);

        builder.Property(d => d.Title)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(d => d.Content)
            .IsRequired()
            .HasMaxLength(2000); // İçerikler uzun olabilir, bu yüzden sınırı yüksek tutuyoruz

        builder.Property(d => d.Type)
            .IsRequired();

        builder.Property(d => d.Date)
            .IsRequired();
    }
}
