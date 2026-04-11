using System;
using Domain.Enums;

namespace Application.Common.DTOs.Favorites;

public class FavoriteDto
{
    public Guid Id { get; set; }
    public ContentType Type { get; set; }
    public string ExternalId { get; set; } = null!;
    public int? SurahId { get; set; }
    public int? AyahNumber { get; set; }
    public int? PageNumber { get; set; }
    public string? Title { get; set; }
    public string? ContentArabic { get; set; }
    public string? ContentText { get; set; }
    public DateTime CreatedAt { get; set; }
}
