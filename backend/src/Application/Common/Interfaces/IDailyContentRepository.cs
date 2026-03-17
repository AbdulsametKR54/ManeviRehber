using System.Threading.Tasks;
using Domain.Entities;

using System;
using System.Collections.Generic;

namespace Application.Common.Interfaces;

public interface IDailyContentRepository : IRepository<DailyContent>
{
    Task<(IEnumerable<DailyContent> Items, int TotalCount)> GetPagedAsync(
        string? search,
        DateTime? date,
        int? type,
        Guid? categoryId,
        Guid? specialDayId,
        int page,
        int pageSize
    );
}
