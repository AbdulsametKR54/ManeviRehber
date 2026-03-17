using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Domain.Common;

namespace Domain.Entities;
public class Setting : BaseEntity, IAggregateRoot
{
    // Ayarın anahtar adı (ör: "theme", "notification_enabled")
    public string Key { get; private set; }

    // Ayarın değeri (ör: "dark", "true", "en")
    public string Value { get; private set; }

    // Ayarın açıklaması (opsiyonel)
    public string? Description { get; private set; }

    private Setting() { } // EF Core için gerekli

    public Setting(string key, string value, string? description = null)
    {
        if (string.IsNullOrWhiteSpace(key))
            throw new ArgumentException("Key cannot be empty");

        if (string.IsNullOrWhiteSpace(value))
            throw new ArgumentException("Value cannot be empty");

        Key = key;
        Value = value;
        Description = description;
    }

    // Ayarı güncellemek için kullanılan metod
    public void Update(string value, string? description = null)
    {
        if (string.IsNullOrWhiteSpace(value))
            throw new ArgumentException("Value cannot be empty");

        Value = value;
        Description = description;

        SetUpdated();
    }
}