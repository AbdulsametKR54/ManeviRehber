using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Application.Common.Interfaces;

namespace Infrastructure.Persistence;

public class ApplicationDbContext : DbContext, IApplicationDbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();   
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<PrayerTime> PrayerTimes => Set<PrayerTime>();
    public DbSet<SpecialDay> SpecialDays => Set<SpecialDay>();
    public DbSet<DailyContent> DailyContents => Set<DailyContent>();
    public DbSet<Setting> Settings => Set<Setting>();
    public DbSet<Log> Logs => Set<Log>();
    public DbSet<DailyContentCategory> DailyContentCategories => Set<DailyContentCategory>();
    public DbSet<UserDashboardLayout> UserDashboardLayouts => Set<UserDashboardLayout>();

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default) => base.SaveChangesAsync(cancellationToken);

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
        base.OnModelCreating(modelBuilder);
    }
}