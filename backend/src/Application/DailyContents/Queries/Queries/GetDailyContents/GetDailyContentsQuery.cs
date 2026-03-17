using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.DTOs.DailyContents;
using Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.DailyContents.Queries.GetDailyContents;

public class GetDailyContentsQuery : IRequest<List<DailyContentDto>>
{
    public Guid? SpecialDayId { get; set; }
    public Guid? CategoryId { get; set; }
}
