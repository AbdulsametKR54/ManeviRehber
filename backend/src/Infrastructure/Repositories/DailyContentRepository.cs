using System;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Domain.Entities;
using Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class DailyContentRepository : IDailyContentRepository
{
    private readonly ApplicationDbContext _context;

    public DailyContentRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<DailyContent?> GetByIdAsync(Guid id)
    {
        return await _context.DailyContents
            .Include(x => x.SpecialDay)
            .Include(x => x.DailyContentCategories)
                .ThenInclude(dcc => dcc.Category)
            .FirstOrDefaultAsync(x => x.Id == id);
    }

    public async Task<(IEnumerable<DailyContent> Items, int TotalCount)> GetPagedAsync(
        string? search,
        DateTime? date,
        int? type,
        Guid? categoryId,
        Guid? specialDayId,
        int page,
        int pageSize)
    {
        var query = _context.DailyContents
            .Include(x => x.SpecialDay)
            .Include(x => x.DailyContentCategories)
                .ThenInclude(dcc => dcc.Category)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(search))
        {
            var searchLower = search.ToLower();
            query = query.Where(x => 
                (x.Title != null && x.Title.ToLower().Contains(searchLower)) || 
                (x.Content != null && x.Content.ToLower().Contains(searchLower)));
        }

        if (date.HasValue)
        {
            var dateOnly = DateOnly.FromDateTime(date.Value);
            query = query.Where(x => x.Date == dateOnly);
        }

        if (type.HasValue)
        {
            query = query.Where(x => (int)x.Type == type.Value);
        }

        if (categoryId.HasValue)
        {
            query = query.Where(x => x.DailyContentCategories.Any(dcc => dcc.CategoryId == categoryId.Value));
        }

        if (specialDayId.HasValue)
        {
            query = query.Where(x => x.SpecialDayId == specialDayId.Value);
        }

        var totalCount = await query.CountAsync();

        var items = await query
            .OrderByDescending(x => x.Date)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return (items, totalCount);
    }

    public async Task AddAsync(DailyContent dailyContent)
    {
        await _context.DailyContents.AddAsync(dailyContent);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(DailyContent dailyContent)
    {
        _context.DailyContents.Update(dailyContent);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(DailyContent dailyContent)
    {
        _context.DailyContents.Remove(dailyContent);
        await _context.SaveChangesAsync();
    }
}
