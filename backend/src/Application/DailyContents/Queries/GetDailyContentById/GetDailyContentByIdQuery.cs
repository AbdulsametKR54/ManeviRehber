using System;
using Application.Common.DTOs.DailyContents;
using MediatR;

namespace Application.DailyContents.Queries.GetDailyContentById;

public class GetDailyContentByIdQuery : IRequest<DailyContentDto?>
{
    public Guid Id { get; set; }
}
