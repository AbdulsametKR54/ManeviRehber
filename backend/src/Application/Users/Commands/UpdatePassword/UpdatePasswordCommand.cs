using MediatR;

namespace Application.Users.Commands.UpdatePassword;

public record UpdatePasswordCommand(Guid UserId, string OldPassword, string NewPassword) : IRequest;
