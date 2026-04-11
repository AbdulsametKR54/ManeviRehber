using System;
using Domain.Common;
using Domain.Enums;

namespace Domain.Entities;

public class Favorite : BaseEntity
{
    public Guid UserId { get; private set; }
    public ContentType Type { get; private set; }
    
    // Identifier for the content (e.g., "surahId:ayahNumber" or DailyContent Id)
    public string ExternalId { get; private set; } = null!;
    
    // Metadata for quick display and navigation
    public int? SurahId { get; private set; }
    public int? AyahNumber { get; private set; }
    public int? PageNumber { get; private set; }
    
    public string? Title { get; private set; }
    public string? ContentArabic { get; private set; }
    public string? ContentText { get; private set; }

    private Favorite() { } // For EF Core

    public Favorite(
        Guid userId, 
        ContentType type, 
        string externalId, 
        int? surahId = null, 
        int? ayahNumber = null, 
        int? pageNumber = null,
        string? title = null,
        string? contentArabic = null,
        string? contentText = null)
    {
        UserId = userId;
        Type = type;
        ExternalId = externalId;
        SurahId = surahId;
        AyahNumber = ayahNumber;
        PageNumber = pageNumber;
        Title = title;
        ContentArabic = contentArabic;
        ContentText = contentText;
    }

    public static Favorite CreateAyah(
        Guid userId, 
        int surahId, 
        int ayahNumber, 
        int pageNumber, 
        string surahName, 
        string arabic, 
        string translation)
    {
        return new Favorite(
            userId,
            ContentType.Verse,
            $"{surahId}:{ayahNumber}",
            surahId,
            ayahNumber,
            pageNumber,
            $"{surahName} {ayahNumber}",
            arabic,
            translation
        );
    }

    public static Favorite CreateDailyContent(
        Guid userId, 
        ContentType type, 
        Guid contentId, 
        string title, 
        string content)
    {
        return new Favorite(
            userId,
            type,
            contentId.ToString(),
            title: title,
            contentText: content
        );
    }
}
