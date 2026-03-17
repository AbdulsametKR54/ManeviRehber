using System;
using MediatR;

namespace Application.SpecialDays.Commands.UpdateSpecialDay;

public class UpdateSpecialDayCommand : IRequest<Unit>
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateOnly Date { get; set; }
    public string Description { get; set; } = string.Empty;
}
