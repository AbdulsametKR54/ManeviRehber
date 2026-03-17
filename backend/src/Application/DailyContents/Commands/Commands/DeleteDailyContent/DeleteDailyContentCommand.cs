using System;
using MediatR;

namespace Application.DailyContents.Commands.DeleteDailyContent;

public class DeleteDailyContentCommand : IRequest<Unit>
{
    public Guid Id { get; set; }
}
