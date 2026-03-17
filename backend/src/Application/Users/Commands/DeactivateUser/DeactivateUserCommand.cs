using System;
using MediatR;

namespace Application.Users.Commands.DeactivateUser;

public class DeactivateUserCommand : IRequest<Unit>
{
    public Guid Id { get; set; }
}
