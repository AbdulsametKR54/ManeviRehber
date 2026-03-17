using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Domain.Entities;
using MediatR;

namespace Application.SpecialDays.Commands.CreateSpecialDay;

public class CreateSpecialDayCommand : IRequest<Guid>
{
    public string Name { get; set; } = string.Empty;
    public DateOnly Date { get; set; }
    public string Description { get; set; } = string.Empty;
}
