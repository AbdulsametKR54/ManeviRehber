using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Domain.Entities;

namespace Application.Common.Interfaces;

public interface IFavoriteRepository : IRepository<Favorite>
{
    Task<List<Favorite>> GetByUserIdAsync(Guid userId);
}
