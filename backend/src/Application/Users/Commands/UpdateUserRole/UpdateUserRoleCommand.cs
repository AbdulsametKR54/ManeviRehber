using System;
using MediatR;

namespace Application.Users.Commands.UpdateUserRole;

public class UpdateUserRoleCommand : IRequest<Unit>
{
    public Guid Id { get; set; }
    public string Role { get; set; } = default!;
}
