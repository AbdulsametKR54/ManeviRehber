using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
namespace Application.Users.Commands.LoginUser;

public class LoginUserResultDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = default!;
    public string Email { get; set; } = default!;
    public string Language { get; set; } = default!;
    public string Token { get; set; } = default!;
}