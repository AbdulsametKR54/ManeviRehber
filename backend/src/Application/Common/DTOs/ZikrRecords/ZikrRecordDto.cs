using System;

namespace Application.Common.DTOs.ZikrRecords;

public class ZikrRecordDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Phrase { get; set; }
    public int Count { get; set; }
    public DateOnly Date { get; set; }
}

public class ZikrDailySummaryDto
{
    public DateOnly Date {get; set;}
    public string Phrase {get; set;}
    public int Total {get; set;}
}
