using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.DTOs.SpecialDays;
using Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.SpecialDays.Queries.GetSpecialDays;

public class GetSpecialDaysQuery : IRequest<List<SpecialDayDto>>
{
}
