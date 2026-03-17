using System;
using Domain.Common;

namespace Domain.Entities;

public class DailyContentCategory : BaseEntity
{
    public Guid DailyContentId { get; set; }
    public DailyContent DailyContent { get; set; } = null!;

    public Guid CategoryId { get; set; }
    public Category Category { get; set; } = null!;
}
