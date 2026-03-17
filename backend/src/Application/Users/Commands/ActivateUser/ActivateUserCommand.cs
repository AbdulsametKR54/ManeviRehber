using System;
using MediatR;

namespace Application.Users.Commands.ActivateUser;

public class ActivateUserCommand : IRequest<Unit>
{
    public Guid Id { get; set; }
}
