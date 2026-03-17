using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MediatR;
using Application.Common.Interfaces;
using Newtonsoft.Json;
using System.Threading;

namespace Application.Users.Commands.UpdateUserName;
public class UpdateUserNameCommandHandler : IRequestHandler<UpdateUserNameCommand>
{
    private readonly IUserRepository _userRepository;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateUserNameCommandHandler(
        IUserRepository userRepository,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _userRepository = userRepository;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(UpdateUserNameCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.UserId);

        if (user == null)
            throw new Exception("Kullanıcı bulunamadı.");

        var oldName = user.Name;

        user.ChangeName(request.Name);

        await _userRepository.UpdateAsync(user);

        await _logRepository.AddAsync(new Domain.Entities.Log(
            _currentUserService.UserId ?? Guid.Empty,
            "User.UpdateName",
            $"Updated Name for User {user.Id}",
            JsonConvert.SerializeObject(new { OldName = oldName, NewName = request.Name }),
            _currentUserService.IpAddress
        ));

        return Unit.Value;
    }
}