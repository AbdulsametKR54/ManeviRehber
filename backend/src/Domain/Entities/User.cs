using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Domain.Common;
using Domain.ValueObjects;
using Domain.Enums;

namespace Domain.Entities;

public class User : BaseEntity, IAggregateRoot
{
    // Kullanıcının adı
    public string Name { get; private set; }

    // Kullanıcının e-posta adresi (Value Object)
    public Email Email { get; private set; }

    // Hashlenmiş şifre (asla düz şifre tutulmaz)
    public string PasswordHash { get; private set; }

    // Kullanıcının tercih ettiği dil
    public Language Language { get; private set; }

    public UserRole Role { get; private set; }

    public bool IsActive { get; private set; } = true;

    private User() 
    {
        Name = null!;
        Email = null!;
        PasswordHash = null!;
    } // EF Core için gerekli

    public User(string name, Email email, string passwordHash, Language language, UserRole role = UserRole.User)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Name cannot be empty");

        if (string.IsNullOrWhiteSpace(passwordHash))
            throw new ArgumentException("PasswordHash cannot be empty");

        Name = name;
        Email = email;
        PasswordHash = passwordHash;
        Language = language;
        Role = role;
    }

    public static User Create(string name, string email, string passwordHash, string language, UserRole role = UserRole.User)
    {
        // Email VO oluştur
        var emailVo = Email.Create(email);

        // Language enum parse et
        if (!Enum.TryParse<Language>(language, true, out var langEnum))
            throw new ArgumentException("Invalid language value");

        // User oluştur
        return new User(name, emailVo, passwordHash, langEnum, role);
    }

    // Kullanıcının adını değiştirmek için kullanılan metod
    public void ChangeName(string newName)
    {
        if (string.IsNullOrWhiteSpace(newName))
            throw new ArgumentException("Name cannot be empty");

        Name = newName;
        SetUpdated();
    }

    // Kullanıcının dil tercihini değiştirmek için kullanılan metod
    public void ChangeLanguage(Language language)
    {
        Language = language;
        SetUpdated();
    }

    // Kullanıcının email tercihini değiştirmek için kullanılan metod
    public void ChangeEmail(string newEmail)
    {
        Email = Email.Create(newEmail);
        SetUpdated();
    }

    public void ChangePassword(string newPasswordHash)
    {
        PasswordHash = newPasswordHash;
        UpdatedAt = DateTime.UtcNow;
    }

    public void ChangeRole(UserRole role)
    {
        Role = role;
        SetUpdated();
    }

    public void Activate()
    {
        IsActive = true;
        SetUpdated();
    }

    public void Deactivate()
    {
        IsActive = false;
        SetUpdated();
    }
}