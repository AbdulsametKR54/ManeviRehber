using Application.Common.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class QuranController : ControllerBase
{
    private readonly IQuranService _quranService;

    public QuranController(IQuranService quranService)
    {
        _quranService = quranService;
    }

    [HttpGet("surahs")]
    public async Task<IActionResult> GetSurahs()
    {
        var surahs = await _quranService.GetSurahsAsync();
        return Ok(surahs);
    }

    [HttpGet("reciters")]
    public async Task<IActionResult> GetReciters()
    {
        var reciters = await _quranService.GetRecitersAsync();
        return Ok(reciters);
    }

    [HttpGet("surahs/{surahId}/ayahs")]
    public async Task<IActionResult> GetAyahs(int surahId)
    {
        var ayahs = await _quranService.GetAyahsBySurahIdAsync(surahId);
        return Ok(ayahs);
    }

    [HttpGet("surahs/{surahId}/all-images")]
    public async Task<IActionResult> GetSurahImages(int surahId)
    {
        var images = await _quranService.GetSurahImagesAsync(surahId);
        return Ok(images);
    }

    [HttpGet("surahs/{surahId}/ayahs/{ayahId}/images")]
    public async Task<IActionResult> GetAyahImages(int surahId, int ayahId)
    {
        var images = await _quranService.GetAyahImagesAsync(surahId, ayahId);
        return Ok(images);
    }

    [HttpGet("audio/{reciter}/{surahId}/{ayahId}")]
    public async Task<IActionResult> GetAyahAudio(string reciter, int surahId, int ayahId)
    {
        var audioPath = await _quranService.GetAyahAudioPathAsync(reciter, surahId, ayahId);
        return Ok(new { AudioPath = audioPath });
    }

    [HttpGet("audio/{reciter}/{surahId}/all")]
    public async Task<IActionResult> GetFullSurahAudio(string reciter, int surahId)
    {
        var urls = await _quranService.GetFullSurahAudioUrlsAsync(reciter, surahId);
        return Ok(urls);
    }

    [HttpGet("meal/{language}/{surahId}")]
    public IActionResult GetMealAudio(string language, int surahId)
    {
        var url = _quranService.GetMealAudioUrl(language, surahId);
        return Ok(new { url });
    }

    [HttpGet("surahs/{surahId}/integrity")]
    public async Task<IActionResult> CheckIntegrity(int surahId)
    {
        var result = await _quranService.CheckSurahIntegrityAsync(surahId);
        return Ok(result);
    }
}
