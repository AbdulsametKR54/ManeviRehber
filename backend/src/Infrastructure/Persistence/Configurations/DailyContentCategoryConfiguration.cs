using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Infrastructure.Persistence.Configurations;

public class DailyContentCategoryConfiguration : IEntityTypeConfiguration<DailyContentCategory>
{
    public void Configure(EntityTypeBuilder<DailyContentCategory> builder)
    {
        builder.ToTable("DailyContentCategories");

        builder.HasKey(dcc => dcc.Id);

        builder.HasOne(dcc => dcc.DailyContent)
            .WithMany(dc => dc.DailyContentCategories)
            .HasForeignKey(dcc => dcc.DailyContentId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(dcc => dcc.Category)
            .WithMany(c => c.DailyContentCategories)
            .HasForeignKey(dcc => dcc.CategoryId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
