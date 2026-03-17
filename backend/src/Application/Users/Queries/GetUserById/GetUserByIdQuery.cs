using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MediatR;

namespace Application.Users.Queries.GetUserById;

public class GetUserByIdQuery : IRequest<UserDto>
{
    public Guid Id { get; set; }
}