using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using System.Threading;
using System.Threading.Tasks;

namespace Application.Common.Interfaces;

public interface IApplicationDbContext
{
    // Tablolar
    DbSet<User> Users { get; }
    DbSet<Category> Categories { get; }
    DbSet<PrayerTime> PrayerTimes { get; }
    DbSet<SpecialDay> SpecialDays { get; }
    DbSet<DailyContent> DailyContents { get; }
    DbSet<Setting> Settings { get; }
    DbSet<Log> Logs { get; }
    DbSet<DailyContentCategory> DailyContentCategories { get; }
    DbSet<UserDashboardLayout> UserDashboardLayouts { get; }

    // SaveChanges
    Task<int> SaveChangesAsync(CancellationToken cancellationToken);
}
