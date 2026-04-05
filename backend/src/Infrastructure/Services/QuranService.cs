using Application.Common.DTOs.Quran;
using Application.Common.DTOs.Quran.OpenApi;
using Application.Common.Interfaces;

namespace Infrastructure.Services;

public class QuranService : IQuranService
{
    private readonly IQuranInternalService _internalService;
    private readonly IQuranOpenApiService _openApiService;

    public QuranService(IQuranInternalService internalService, IQuranOpenApiService openApiService)
    {
        _internalService = internalService;
        _openApiService = openApiService;
    }

    // Internal Service methods
    public Task<List<SurahDto>> GetSurahsAsync() => _internalService.GetSurahsAsync();
    public Task<List<ReciterDto>> GetRecitersAsync() => _internalService.GetRecitersAsync();
    public Task<List<AyahDto>> GetAyahsBySurahIdAsync(int surahId) => _internalService.GetAyahsBySurahIdAsync(surahId);
    public Task<List<string>> GetAyahImagesAsync(int surahId, int ayahId) => _internalService.GetAyahImagesAsync(surahId, ayahId);
    public Task<string> GetAyahAudioPathAsync(string reciter, int surahId, int ayahId) => _internalService.GetAyahAudioPathAsync(reciter, surahId, ayahId);
    public Task<List<string>> GetFullSurahAudioUrlsAsync(string reciter, int surahId) => _internalService.GetFullSurahAudioUrlsAsync(reciter, surahId);
    public Task<Dictionary<int, List<string>>> GetSurahImagesAsync(int surahId) => _internalService.GetSurahImagesAsync(surahId);
    public string GetMealAudioUrl(string language, int surahId) => _internalService.GetMealAudioUrl(language, surahId);
    public Task<QuranTestResultDto> CheckSurahIntegrityAsync(int surahId) => _internalService.CheckSurahIntegrityAsync(surahId);

    // OpenApi Service methods
    public Task<object?> GetSurahDetailsAsync(int surahId) => _openApiService.GetSurahDetailsAsync(surahId);
    public Task<object?> GetVerseDetailAsync(int surahId, int ayahId) => _openApiService.GetVerseDetailAsync(surahId, ayahId);
    public Task<object?> GetVerseTranslationsAsync(int surahId, int ayahId) => _openApiService.GetVerseTranslationsAsync(surahId, ayahId);
    public Task<object?> GetVersePartsAsync(int surahId, int ayahId) => _openApiService.GetVersePartsAsync(surahId, ayahId);
    public Task<object?> GetRootDetailsAsync(string latin) => _openApiService.GetRootDetailsAsync(latin);
    public Task<object?> GetRootVersePartsAsync(string latin) => _openApiService.GetRootVersePartsAsync(latin);
    public Task<object?> GetPageVersesAsync(int pageNumber) => _openApiService.GetPageVersesAsync(pageNumber);
}
