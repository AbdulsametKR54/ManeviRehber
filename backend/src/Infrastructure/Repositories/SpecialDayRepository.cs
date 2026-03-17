using System;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Domain.Entities;
using Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class SpecialDayRepository : ISpecialDayRepository
{
    private readonly ApplicationDbContext _context;

    public SpecialDayRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<SpecialDay?> GetByIdAsync(Guid id)
    {
        return await _context.SpecialDays.FirstOrDefaultAsync(x => x.Id == id);
    }

    public async Task<(IEnumerable<SpecialDay> Items, int TotalCount)> GetPagedAsync(string? search, int page, int pageSize)
    {
        var query = _context.SpecialDays.AsQueryable();

        if (!string.IsNullOrWhiteSpace(search))
        {
            var searchLower = search.ToLower();
            query = query.Where(x => 
                (x.Name != null && x.Name.ToLower().Contains(searchLower)) || 
                (x.Description != null && x.Description.ToLower().Contains(searchLower)));
        }

        var totalCount = await query.CountAsync();

        var items = await query
            .OrderBy(x => x.Date)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return (items, totalCount);
    }

    public async Task AddAsync(SpecialDay specialDay)
    {
        await _context.SpecialDays.AddAsync(specialDay);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(SpecialDay specialDay)
    {
        _context.SpecialDays.Update(specialDay);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(SpecialDay specialDay)
    {
        _context.SpecialDays.Remove(specialDay);
        await _context.SaveChangesAsync();
    }
}
