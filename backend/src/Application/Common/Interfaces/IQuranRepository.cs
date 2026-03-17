using Application.Common.DTOs.Quran;

namespace Application.Common.Interfaces;

public interface IQuranRepository
{
    Task<List<SurahDto>> GetSurahsAsync();
    Task<List<ReciterDto>> GetRecitersAsync();
    Task<List<AyahDto>> GetAyahsBySurahIdAsync(int surahId);
    Task<List<string>> GetAyahImagesAsync(int surahId, int ayahId);
    Task<string> GetAyahAudioPathAsync(string reciter, int surahId, int ayahId);
}
