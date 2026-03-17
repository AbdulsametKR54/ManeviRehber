using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Api.Models.Users;

public class UpdatePasswordRequest
{
    public required string OldPassword { get; set; }
    public required string NewPassword { get; set; }
}