using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Infrastructure.Persistence.Configurations;

public class LogConfiguration : IEntityTypeConfiguration<Log>
{
    public void Configure(EntityTypeBuilder<Log> builder)
    {
        builder.HasKey(x => x.Id);

        builder.Property(x => x.Action)
            .IsRequired()
            .HasMaxLength(150);

        builder.Property(x => x.Description)
            .HasMaxLength(500);

        builder.Property(x => x.IpAddress)
            .HasMaxLength(50);

        builder.Property(x => x.Platform)
            .HasMaxLength(50);

        builder.Property(x => x.Endpoint)
            .HasMaxLength(255);
            
        // Data kolonu NVarChar(Max) olarak otomatik ayarlanır, ancak biz istersen explicitly belirtebiliriz
    }
}
