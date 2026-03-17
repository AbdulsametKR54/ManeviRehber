using System;
using Application.Common.DTOs.SpecialDays;
using MediatR;

namespace Application.SpecialDays.Queries.GetSpecialDayById;

public class GetSpecialDayByIdQuery : IRequest<SpecialDayDto?>
{
    public Guid Id { get; set; }
}
