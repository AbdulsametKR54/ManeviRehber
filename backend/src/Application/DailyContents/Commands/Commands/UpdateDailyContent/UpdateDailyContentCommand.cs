using System;
using Domain.Enums;
using MediatR;

namespace Application.DailyContents.Commands.UpdateDailyContent;

public class UpdateDailyContentCommand : IRequest<Unit>
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public ContentType Type { get; set; }
    public DateOnly Date { get; set; }
    public Guid? SpecialDayId { get; set; }
    public List<Guid> CategoryIds { get; set; } = new List<Guid>();
}
