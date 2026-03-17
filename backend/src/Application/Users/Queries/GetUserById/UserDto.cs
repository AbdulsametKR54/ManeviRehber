using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
namespace Application.Users.Queries.GetUserById;

public class UserDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = default!;
    public string Email { get; set; } = default!;
    public string Language { get; set; } = default!;
    public string Role { get; set; } = default!;
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
}