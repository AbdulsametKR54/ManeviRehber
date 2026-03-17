using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Infrastructure.Persistence;

namespace Infrastructure.Repositories;

public class PrayerTimeRepository : IPrayerTimeRepository
{
    private readonly ApplicationDbContext _context;

    public PrayerTimeRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<PrayerTime?> GetByDateAsync(int locationId, DateOnly date, CancellationToken cancellationToken)
    {
        return await _context.PrayerTimes
            .FirstOrDefaultAsync(x => x.LocationId == locationId && x.Date == date, cancellationToken);
    }

    public async Task<List<PrayerTime>> GetMonthlyAsync(int locationId, int year, int month, CancellationToken cancellationToken)
    {
        return await _context.PrayerTimes
            .Where(x => x.LocationId == locationId && x.Date.Year == year && x.Date.Month == month)
            .OrderBy(x => x.Date)
            .ToListAsync(cancellationToken);
    }

    public async Task<bool> ExistsAsync(int locationId, DateOnly date, CancellationToken cancellationToken)
    {
        return await _context.PrayerTimes
            .AnyAsync(x => x.LocationId == locationId && x.Date == date, cancellationToken);
    }

    public async Task AddAsync(PrayerTime entity, CancellationToken cancellationToken)
    {
        await _context.PrayerTimes.AddAsync(entity, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
