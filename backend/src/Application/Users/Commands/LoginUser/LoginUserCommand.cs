using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MediatR;

namespace Application.Users.Commands.LoginUser;

public class LoginUserCommand : IRequest<LoginUserResultDto>
{
    public string Email { get; set; } = default!;
    public string Password { get; set; } = default!;
}