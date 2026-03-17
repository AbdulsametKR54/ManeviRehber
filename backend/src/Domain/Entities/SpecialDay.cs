using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Domain.Common;

namespace Domain.Entities;

public class SpecialDay : BaseEntity, IAggregateRoot
{
    // Özel günün adı (ör: Kadir Gecesi, Miraç Kandili)
    public string Name { get; private set; }

    // Özel günün tarihi
    public DateOnly Date { get; private set; }

    // Özel gün hakkında açıklama veya detaylı bilgi
    public string Description { get; private set; }

    private SpecialDay() { } // EF Core için gerekli

    public SpecialDay(string name, DateOnly date, string description)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Name cannot be empty");

        if (string.IsNullOrWhiteSpace(description))
            throw new ArgumentException("Description cannot be empty");

        Name = name;
        Date = date;
        Description = description;
    }

    // Özel gün bilgilerini güncellemek için kullanılan metod
    public void Update(string name, DateOnly date, string description)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Name cannot be empty");

        if (string.IsNullOrWhiteSpace(description))
            throw new ArgumentException("Description cannot be empty");

        Name = name;
        Date = date;
        Description = description;

        SetUpdated();
    }
}