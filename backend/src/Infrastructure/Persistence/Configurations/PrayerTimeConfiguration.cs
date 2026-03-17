using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Infrastructure.Persistence.Configurations;

public class PrayerTimeConfiguration : IEntityTypeConfiguration<PrayerTime>
{
    public void Configure(EntityTypeBuilder<PrayerTime> builder)
    {
        // Tablo adı
        builder.ToTable("PrayerTimes");

        // Primary Key
        builder.HasKey(x => x.Id);

        // LocationId zorunlu
        builder.Property(x => x.LocationId)
            .IsRequired();

        // Tarih zorunlu
        builder.Property(x => x.Date)
            .IsRequired();

        // TimeOnly alanları zorunlu
        builder.Property(x => x.Fajr).IsRequired();
        builder.Property(x => x.Sunrise).IsRequired();
        builder.Property(x => x.Dhuhr).IsRequired();
        builder.Property(x => x.Asr).IsRequired();
        builder.Property(x => x.Maghrib).IsRequired();
        builder.Property(x => x.Sunset).IsRequired();
        builder.Property(x => x.Isha).IsRequired();

        // Hicrî tarih
        builder.Property(x => x.HijriDateLong)
            .HasMaxLength(50)
            .IsRequired();

        // 🔥 En kritik index:
        // Aynı LocationId + Date kombinasyonu bir kez bulunabilir
        builder.HasIndex(x => new { x.LocationId, x.Date })
            .IsUnique();
    }
}
