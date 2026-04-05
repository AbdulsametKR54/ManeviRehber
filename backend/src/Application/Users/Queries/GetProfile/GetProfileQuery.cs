using MediatR;

namespace Application.Users.Queries.GetProfile;

public class GetProfileQuery : IRequest<UserProfileDto>
{
}
