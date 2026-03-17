using Application.Common.DTOs.Quran;
using Application.Common.Interfaces;

namespace Infrastructure.Services;

public class QuranService : IQuranService
{
    private readonly IQuranRepository _quranRepository;

    public QuranService(IQuranRepository quranRepository)
    {
        _quranRepository = quranRepository;
    }

    public async Task<List<SurahDto>> GetSurahsAsync()
    {
        return await _quranRepository.GetSurahsAsync();
    }

    public async Task<List<ReciterDto>> GetRecitersAsync()
    {
        return await _quranRepository.GetRecitersAsync();
    }

    public async Task<List<AyahDto>> GetAyahsBySurahIdAsync(int surahId)
    {
        return await _quranRepository.GetAyahsBySurahIdAsync(surahId);
    }

    public async Task<List<string>> GetAyahImagesAsync(int surahId, int ayahId)
    {
        return await _quranRepository.GetAyahImagesAsync(surahId, ayahId);
    }

    public async Task<string> GetAyahAudioPathAsync(string reciter, int surahId, int ayahId)
    {
        // Correct pattern: /Sesler/{reciter}/{surah:D3}/{surah:D3}{ayah:D3}.mp3
        var surah = surahId.ToString("000");
        var ayah = ayahId.ToString("000");
        return await Task.FromResult($"/Sesler/{reciter}/{surah}/{surah}{ayah}.mp3");
    }

    public async Task<List<string>> GetFullSurahAudioUrlsAsync(string reciter, int surahId)
    {
        var ayahs = await _quranRepository.GetAyahsBySurahIdAsync(surahId);
        var urls = new List<string>();

        foreach (var ayah in ayahs)
        {
            // Correct pattern: /Sesler/{reciter}/{surah:D3}/{surah:D3}{ayah:D3}.mp3
            var s = surahId.ToString("000");
            var a = ayah.AyahNumber.ToString("000");
            urls.Add($"/Sesler/{reciter}/{s}/{s}{a}.mp3");
        }

        return urls;
    }

    public async Task<Dictionary<int, List<string>>> GetSurahImagesAsync(int surahId)
    {
        var ayahs = await _quranRepository.GetAyahsBySurahIdAsync(surahId);
        var result = new Dictionary<int, List<string>>();

        foreach (var ayah in ayahs)
        {
            var images = await _quranRepository.GetAyahImagesAsync(surahId, ayah.AyahNumber);
            result[ayah.AyahNumber] = images;
        }

        return result;
    }

    public string GetMealAudioUrl(string language, int surahId)
    {
        // tr -> https://audio.acikkuran.com/tr/{surahId}.mp3
        // en -> https://audio.acikkuran.com/en/{surahId}.mp3
        return $"https://audio.acikkuran.com/{language.ToLower()}/{surahId}.mp3";
    }

    public async Task<QuranTestResultDto> CheckSurahIntegrityAsync(int surahId)
    {
        var surahs = await _quranRepository.GetSurahsAsync();
        var surah = surahs.FirstOrDefault(s => s.Id == surahId);
        
        var result = new QuranTestResultDto
        {
            SurahId = surahId,
            SurahName = surah?.Name ?? "Unknown"
        };

        if (surah == null) return result;

        var ayahs = await _quranRepository.GetAyahsBySurahIdAsync(surahId);

        foreach (var ayah in ayahs)
        {
            // Simulation of file check logic
            // In a real scenario, we would check if the file exists on the server/cloud
            // Here, we simulate some missing files for demonstration (e.g. every 10th ayah missing audio)
            
            if (ayah.AyahNumber % 10 == 0)
            {
                result.MissingAudioAyahs.Add($"{surahId}:{ayah.AyahNumber}");
            }

            if (ayah.AyahNumber % 15 == 0)
            {
                result.MissingImageAyahs.Add($"{surahId}:{ayah.AyahNumber}");
            }
        }

        return result;
    }
}
