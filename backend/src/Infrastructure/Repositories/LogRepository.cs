using System;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Domain.Entities;
using Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class LogRepository : ILogRepository
{
    private readonly ApplicationDbContext _context;

    public LogRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<Log?> GetByIdAsync(Guid id)
    {
        return await _context.Logs.FirstOrDefaultAsync(x => x.Id == id);
    }

    public async Task AddAsync(Log log)
    {
        await _context.Logs.AddAsync(log);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(Log entity)
    {
        _context.Logs.Update(entity);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(Log entity)
    {
        _context.Logs.Remove(entity);
        await _context.SaveChangesAsync();
    }
}
