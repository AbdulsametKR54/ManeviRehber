using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.DTOs.Settings;
using Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Settings.Queries.GetSettings;

public class GetSettingsQuery : IRequest<List<SettingDto>>
{
}
