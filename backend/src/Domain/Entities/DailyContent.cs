using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Domain.Common;
using Domain.Enums;

namespace Domain.Entities;

public class DailyContent : BaseEntity, IAggregateRoot
{
    // İçeriğin başlığı (ör: "Günün Hadisi")
    public string Title { get; private set; }

    // İçeriğin metni (ör: hadis, ayet, dua, söz)
    public string Content { get; private set; }

    // İçeriğin türü (Hadis, Ayet, Dua, Söz)
    public ContentType Type { get; private set; }

    // İçeriğin gösterileceği gün
    public DateOnly Date { get; private set; }

    public Guid? SpecialDayId { get; private set; }
    public SpecialDay? SpecialDay { get; private set; }

    public ICollection<DailyContentCategory> DailyContentCategories { get; private set; } = new List<DailyContentCategory>();

    private DailyContent() { } // EF Core için

    public DailyContent(string title, string content, ContentType type, DateOnly date, Guid? specialDayId = null)
    {
        if (string.IsNullOrWhiteSpace(title))
            throw new ArgumentException("Title cannot be empty");

        if (string.IsNullOrWhiteSpace(content))
            throw new ArgumentException("Content cannot be empty");

        Title = title;
        Content = content;
        Type = type;
        Date = date;
        SpecialDayId = specialDayId;
    }

    // İçeriği güncellemek için kullanılan metod
    public void Update(string title, string content, ContentType type, DateOnly date, Guid? specialDayId)
    {
        if (string.IsNullOrWhiteSpace(title))
            throw new ArgumentException("Title cannot be empty");

        if (string.IsNullOrWhiteSpace(content))
            throw new ArgumentException("Content cannot be empty");

        Title = title;
        Content = content;
        Type = type;
        Date = date;
        SpecialDayId = specialDayId;

        SetUpdated();
    }
}