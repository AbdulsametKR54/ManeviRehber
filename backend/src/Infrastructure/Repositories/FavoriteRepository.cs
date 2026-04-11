using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Domain.Entities;
using Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class FavoriteRepository : IFavoriteRepository
{
    private readonly ApplicationDbContext _context;

    public FavoriteRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<Favorite?> GetByIdAsync(Guid id)
    {
        return await _context.Favorites.FirstOrDefaultAsync(x => x.Id == id);
    }

    public async Task<List<Favorite>> GetByUserIdAsync(Guid userId)
    {
        return await _context.Favorites
            .Where(x => x.UserId == userId)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();
    }

    public async Task AddAsync(Favorite favorite)
    {
        await _context.Favorites.AddAsync(favorite);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(Favorite favorite)
    {
        _context.Favorites.Update(favorite);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(Favorite favorite)
    {
        _context.Favorites.Remove(favorite);
        await _context.SaveChangesAsync();
    }
}
