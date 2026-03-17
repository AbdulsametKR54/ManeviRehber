using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
namespace Application.Common.Interfaces;

public interface IJwtTokenService
{
    string GenerateToken(Domain.Entities.User user);
}