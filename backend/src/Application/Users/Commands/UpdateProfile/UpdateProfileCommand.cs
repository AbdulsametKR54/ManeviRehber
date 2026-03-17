using System;
using MediatR;

namespace Application.Users.Commands.UpdateProfile;

public class UpdateProfileCommand : IRequest<Unit>
{
    public string? Email { get; set; }
    public string? Password { get; set; }
}
