using System;
using Domain.Enums;

namespace Application.Common.DTOs.DailyContents;

public class DailyContentDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public ContentType Type { get; set; }
    public string TypeName { get; set; } = string.Empty;
    public DateOnly Date { get; set; }
    public Guid? SpecialDayId { get; set; }
    public string? SpecialDayName { get; set; }
    public System.Collections.Generic.List<Application.Common.DTOs.Categories.CategoryDto> Categories { get; set; } = new();
}
