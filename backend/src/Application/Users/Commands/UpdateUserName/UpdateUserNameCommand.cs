using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MediatR;
namespace Application.Users.Commands.UpdateUserName;

public record UpdateUserNameCommand(Guid UserId, string Name) : IRequest;
