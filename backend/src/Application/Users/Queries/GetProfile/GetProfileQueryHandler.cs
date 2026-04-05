using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Users.Queries.GetProfile;

public class GetProfileQueryHandler : IRequestHandler<GetProfileQuery, UserProfileDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUserService;

    public GetProfileQueryHandler(IApplicationDbContext context, ICurrentUserService currentUserService)
    {
        _context = context;
        _currentUserService = currentUserService;
    }

    public async Task<UserProfileDto> Handle(GetProfileQuery request, CancellationToken cancellationToken)
    {
        var uid = _currentUserService.UserId;
        if (uid == null)
            throw new Exception("Yetkisiz erişim.");

        var user = await _context.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == uid.Value, cancellationToken);

        if (user == null)
            throw new Exception("Kullanıcı bulunamadı.");

        return new UserProfileDto
        {
            Id = user.Id,
            Name = user.Name,
            Email = user.Email.Value,
            Language = user.Language.ToString()
        };
    }
}
