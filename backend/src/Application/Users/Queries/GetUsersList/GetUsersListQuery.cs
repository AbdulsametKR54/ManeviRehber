using System.Collections.Generic;
using Application.Users.Queries.GetUserById;
using MediatR;

namespace Application.Users.Queries.GetUsersList;

public class PaginatedUserResult
{
    public required List<UserDto> Items { get; set; }
    public int TotalCount { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
}

public class GetUsersListQuery : IRequest<PaginatedUserResult>
{
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 10;
}
