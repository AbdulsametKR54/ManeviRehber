using Application.Common.DTOs.Quran.OpenApi;

namespace Application.Common.Interfaces;

public interface IQuranOpenApiService
{
    Task<object?> GetSurahDetailsAsync(int surahId);
    Task<object?> GetVerseDetailAsync(int surahId, int ayahId);
    Task<object?> GetVerseTranslationsAsync(int surahId, int ayahId);
    Task<object?> GetVersePartsAsync(int surahId, int ayahId);
    Task<object?> GetRootDetailsAsync(string latin);
    Task<object?> GetRootVersePartsAsync(string latin);
    Task<object?> GetPageVersesAsync(int pageNumber);
}
