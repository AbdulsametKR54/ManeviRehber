using System;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Domain.Entities;
using Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class SettingRepository : ISettingRepository
{
    private readonly ApplicationDbContext _context;

    public SettingRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<Setting?> GetByIdAsync(Guid id)
    {
        return await _context.Settings.FirstOrDefaultAsync(x => x.Id == id);
    }

    public async Task AddAsync(Setting setting)
    {
        await _context.Settings.AddAsync(setting);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(Setting setting)
    {
        _context.Settings.Update(setting);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(Setting setting)
    {
        _context.Settings.Remove(setting);
        await _context.SaveChangesAsync();
    }
}
