using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Text.RegularExpressions;

namespace Domain.ValueObjects;

public sealed class Email : IEquatable<Email>
{
    // E-posta adresinin gerçek değeri
    public string Value { get; }

    // Private constructor — dışarıdan new'lenemez, sadece Create ile oluşturulur
    private Email(string value)
    {
        Value = value;
    }

    // Yeni bir Email nesnesi oluşturmak için kullanılan fabrika metodu
    public static Email Create(string email)
    {
        if (string.IsNullOrWhiteSpace(email))
            throw new ArgumentException("Email cannot be empty");

        // E-posta adresini normalize et (boşlukları sil, küçük harfe çevir)
        email = email.Trim().ToLowerInvariant();

        if (!IsValid(email))
            throw new ArgumentException("Invalid email format");

        return new Email(email);
    }

    // E-posta formatının geçerli olup olmadığını kontrol eder
    private static bool IsValid(string email)
    {
        var pattern = @"^[^@\s]+@[^@\s]+\.[^@\s]+$";
        return Regex.IsMatch(email, pattern);
    }

    // Email nesnesini string olarak döndürür
    public override string ToString() => Value;

    // Eşitlik karşılaştırması — iki Email nesnesi aynı değere sahipse eşittir
    public override bool Equals(object? obj) =>
        obj is Email other && Equals(other);

    public bool Equals(Email? other) =>
        other is not null && Value == other.Value;

    // Hash kodu — Value üzerinden hesaplanır
    public override int GetHashCode() =>
        Value.GetHashCode();
}