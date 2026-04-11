using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using MediatR;

namespace Application.Favorites.Commands.DeleteFavorite;

public class DeleteFavoriteCommand : IRequest<Unit>
{
    public Guid Id { get; set; }
}

public class DeleteFavoriteCommandHandler : IRequestHandler<DeleteFavoriteCommand, Unit>
{
    private readonly IFavoriteRepository _favoriteRepository;
    private readonly ICurrentUserService _currentUserService;

    public DeleteFavoriteCommandHandler(IFavoriteRepository favoriteRepository, ICurrentUserService currentUserService)
    {
        _favoriteRepository = favoriteRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteFavoriteCommand request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId ?? throw new UnauthorizedAccessException();
        var favorite = await _favoriteRepository.GetByIdAsync(request.Id);

        if (favorite == null)
            throw new Exception("Favorite not found");

        if (favorite.UserId != userId)
            throw new UnauthorizedAccessException("You are not authorized to delete this favorite");

        await _favoriteRepository.DeleteAsync(favorite);

        return Unit.Value;
    }
}
