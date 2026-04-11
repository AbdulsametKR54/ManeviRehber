using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.DTOs.Favorites;
using Application.Common.Interfaces;
using MediatR;

namespace Application.Favorites.Queries.GetFavorites;

public class GetFavoritesQuery : IRequest<List<FavoriteDto>>
{
}

public class GetFavoritesQueryHandler : IRequestHandler<GetFavoritesQuery, List<FavoriteDto>>
{
    private readonly IFavoriteRepository _favoriteRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetFavoritesQueryHandler(IFavoriteRepository favoriteRepository, ICurrentUserService currentUserService)
    {
        _favoriteRepository = favoriteRepository;
        _currentUserService = currentUserService;
    }

    public async Task<List<FavoriteDto>> Handle(GetFavoritesQuery request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId ?? throw new UnauthorizedAccessException();
        var favorites = await _favoriteRepository.GetByUserIdAsync(userId);

        return favorites.Select(f => new FavoriteDto
        {
            Id = f.Id,
            Type = f.Type,
            ExternalId = f.ExternalId,
            SurahId = f.SurahId,
            AyahNumber = f.AyahNumber,
            PageNumber = f.PageNumber,
            Title = f.Title,
            ContentArabic = f.ContentArabic,
            ContentText = f.ContentText,
            CreatedAt = f.CreatedAt
        }).ToList();
    }
}
