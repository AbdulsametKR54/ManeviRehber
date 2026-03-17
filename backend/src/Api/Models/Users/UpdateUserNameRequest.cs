using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Api.Models.Users;

public class UpdateUserNameRequest
{
    public required string Name { get; set; }
}