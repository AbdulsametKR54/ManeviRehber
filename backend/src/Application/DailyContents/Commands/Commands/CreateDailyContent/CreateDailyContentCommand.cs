using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using MediatR;

namespace Application.DailyContents.Commands.CreateDailyContent;

public class CreateDailyContentCommand : IRequest<Guid>
{
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public ContentType Type { get; set; }
    public DateOnly Date { get; set; }
    public Guid? SpecialDayId { get; set; }
    public List<Guid> CategoryIds { get; set; } = new List<Guid>();
}
