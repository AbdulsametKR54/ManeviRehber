using System.Threading.Tasks;
using Domain.Entities;

using System.Collections.Generic;

namespace Application.Common.Interfaces;

public interface ISpecialDayRepository : IRepository<SpecialDay>
{
    Task<(IEnumerable<SpecialDay> Items, int TotalCount)> GetPagedAsync(string? search, int page, int pageSize);
}
