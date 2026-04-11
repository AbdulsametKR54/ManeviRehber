using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using MediatR;

namespace Application.Favorites.Commands.CreateFavorite;

public class CreateFavoriteCommand : IRequest<Guid>
{
    public ContentType Type { get; set; }
    public string ExternalId { get; set; } = null!;
    public int? SurahId { get; set; }
    public int? AyahNumber { get; set; }
    public int? PageNumber { get; set; }
    public string? Title { get; set; }
    public string? ContentArabic { get; set; }
    public string? ContentText { get; set; }
}

public class CreateFavoriteCommandHandler : IRequestHandler<CreateFavoriteCommand, Guid>
{
    private readonly IFavoriteRepository _favoriteRepository;
    private readonly ICurrentUserService _currentUserService;

    public CreateFavoriteCommandHandler(IFavoriteRepository favoriteRepository, ICurrentUserService currentUserService)
    {
        _favoriteRepository = favoriteRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Guid> Handle(CreateFavoriteCommand request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId ?? throw new UnauthorizedAccessException();

        var favorite = new Favorite(
            userId,
            request.Type,
            request.ExternalId,
            request.SurahId,
            request.AyahNumber,
            request.PageNumber,
            request.Title,
            request.ContentArabic,
            request.ContentText
        );

        await _favoriteRepository.AddAsync(favorite);

        return favorite.Id;
    }
}
