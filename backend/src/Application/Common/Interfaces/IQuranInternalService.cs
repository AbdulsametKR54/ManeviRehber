using Application.Common.DTOs.Quran;

namespace Application.Common.Interfaces;

public interface IQuranInternalService
{
    Task<List<SurahDto>> GetSurahsAsync();
    Task<List<ReciterDto>> GetRecitersAsync();
    Task<List<AyahDto>> GetAyahsBySurahIdAsync(int surahId);
    Task<List<string>> GetAyahImagesAsync(int surahId, int ayahId);
    Task<string> GetAyahAudioPathAsync(string reciter, int surahId, int ayahId);
    Task<List<string>> GetFullSurahAudioUrlsAsync(string reciter, int surahId);
    Task<Dictionary<int, List<string>>> GetSurahImagesAsync(int surahId);
    string GetMealAudioUrl(string language, int surahId);
    Task<QuranTestResultDto> CheckSurahIntegrityAsync(int surahId);
}
