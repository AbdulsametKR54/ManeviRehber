using MediatR;

namespace Application.Users.Commands.UpdateEmail;

public record UpdateEmailCommand(Guid UserId, string Email) : IRequest;