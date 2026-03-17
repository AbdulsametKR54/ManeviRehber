using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Domain.Entities;

namespace Application.Common.Interfaces
{
    public interface ICategoryRepository : IRepository<Category>
    {    
        Task<List<Category>> GetAllAsync();
        Task<(IEnumerable<Category> Items, int TotalCount)> GetPagedAsync(string? search, int page, int pageSize);
    }
}