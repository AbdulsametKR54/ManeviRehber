using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Domain.Entities;

namespace Application.Common.Interfaces;

public interface IPrayerTimeRepository
{
    Task<PrayerTime?> GetByDateAsync(int locationId, DateOnly date, CancellationToken cancellationToken);
    Task<List<PrayerTime>> GetMonthlyAsync(int locationId, int year, int month, CancellationToken cancellationToken);
    Task<bool> ExistsAsync(int locationId, DateOnly date, CancellationToken cancellationToken);
    Task AddAsync(PrayerTime entity, CancellationToken cancellationToken);
}
