using System;
using MediatR;

namespace Application.Users.Commands.UpdateProfile;

public class UpdateProfileCommand : IRequest<Unit>
{
    public string? Name { get; set; }
    public string? Email { get; set; }
    public string? Password { get; set; }
    public string? Language { get; set; }
}
