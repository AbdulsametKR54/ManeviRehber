using System;
using Domain.Common;

namespace Domain.Entities;

public class ZikrRecord : BaseEntity, IAggregateRoot
{
    public Guid UserId { get; private set; }
    public string Phrase { get; private set; } // subhanallah, elhamdulillah, etc.
    public int Count { get; private set; }
    public DateOnly Date { get; private set; }

    private ZikrRecord() { } // Required for EF Core

    public ZikrRecord(Guid userId, string phrase, int count, DateOnly date)
    {
        if (count < 0 || count > 9999)
            throw new ArgumentException("Count must be between 0 and 9999");

        UserId = userId;
        Phrase = phrase;
        Count = count;
        Date = date;
    }

    public void UpdateCount(int count)
    {
        if (count < 0 || count > 9999)
            throw new ArgumentException("Count must be between 0 and 9999");

        Count = count;
        SetUpdated();
    }
}
