using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Domain.Common;

namespace Domain.Entities;

public class Category : BaseEntity, IAggregateRoot
{
    // Kategori adı (ör: Hadis, Dua, Ayet, Ramazan, Ahlak vb.)
    public string Name { get; private set; }

    // Kategori açıklaması (opsiyonel)
    public string? Description { get; private set; }

    public ICollection<DailyContentCategory> DailyContentCategories { get; private set; } = new List<DailyContentCategory>();

    private Category() { } // EF Core için gerekli

    public Category(string name, string? description = null)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Name cannot be empty");

        Name = name;
        Description = description;
    }

    // Kategori bilgilerini güncellemek için kullanılan metod
    public void Update(string name, string? description = null)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Name cannot be empty");

        Name = name;
        Description = description;

        SetUpdated();
    }
}