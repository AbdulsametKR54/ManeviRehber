using System;
using MediatR;

namespace Application.Settings.Commands.UpdateSetting;

public class UpdateSettingCommand : IRequest<Unit>
{
    public Guid Id { get; set; }
    public string Value { get; set; } = string.Empty;
    public string? Description { get; set; }
}
