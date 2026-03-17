using System;
using MediatR;

namespace Application.SpecialDays.Commands.DeleteSpecialDay;

public class DeleteSpecialDayCommand : IRequest<Unit>
{
    public Guid Id { get; set; }
}
