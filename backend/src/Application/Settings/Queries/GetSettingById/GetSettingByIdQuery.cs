using System;
using Application.Common.DTOs.Settings;
using MediatR;

namespace Application.Settings.Queries.GetSettingById;

public class GetSettingByIdQuery : IRequest<SettingDto?>
{
    public Guid Id { get; set; }
}
