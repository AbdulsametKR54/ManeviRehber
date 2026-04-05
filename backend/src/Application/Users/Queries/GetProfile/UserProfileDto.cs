using System;

namespace Application.Users.Queries.GetProfile;

public class UserProfileDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = default!;
    public string Email { get; set; } = default!;
    public string Language { get; set; } = default!;
}
