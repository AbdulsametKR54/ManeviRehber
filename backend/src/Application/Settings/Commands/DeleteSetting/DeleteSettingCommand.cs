using System;
using MediatR;

namespace Application.Settings.Commands.DeleteSetting;

public class DeleteSettingCommand : IRequest<Unit>
{
    public Guid Id { get; set; }
}
