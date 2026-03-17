using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Infrastructure.Persistence.Configurations;

public class UserDashboardLayoutConfiguration : IEntityTypeConfiguration<UserDashboardLayout>
{
    public void Configure(EntityTypeBuilder<UserDashboardLayout> builder)
    {
        builder.HasKey(x => x.Id);

        builder.Property(x => x.UserId)
            .IsRequired();

        // Her kullanıcının sadece 1 layout'u olabilir
        builder.HasIndex(x => x.UserId)
            .IsUnique();

        builder.Property(x => x.WidgetsOrderJson)
            .HasMaxLength(2000);

        builder.Property(x => x.VisibleJson)
            .HasMaxLength(2000);

        builder.Property(x => x.SizeJson)
            .HasMaxLength(2000);

        builder.Property(x => x.AutoRefreshJson)
            .HasMaxLength(2000);

        builder.Property(x => x.AutoRefreshIntervalJson)
            .HasMaxLength(2000);
    }
}
