using System;
using System.Collections.Generic;
using Application.Common.DTOs.ZikrRecords;
using MediatR;

namespace Application.ZikrRecords.Queries.GetDailyZikrSummary;

public class GetDailyZikrSummaryQuery : IRequest<List<ZikrDailySummaryDto>>
{
}
