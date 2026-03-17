using System;
using System.Collections.Generic;
using Application.Common.DTOs.Logs;
using MediatR;

namespace Application.Logs.Queries.GetLogs;

public class GetLogsQuery : IRequest<List<LogDto>>
{
    public Guid? UserId { get; set; }
    public string? Action { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
}
