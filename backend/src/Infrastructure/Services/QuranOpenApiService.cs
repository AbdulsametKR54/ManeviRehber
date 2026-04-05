using System.Net.Http.Json;
using System.Text.Json;
using Application.Common.DTOs.Quran.OpenApi;
using Application.Common.Interfaces;
using Microsoft.Extensions.Caching.Memory;

namespace Infrastructure.Services;

public class QuranOpenApiService : IQuranOpenApiService
{
    private readonly HttpClient _httpClient;
    private readonly IMemoryCache _cache;

    public QuranOpenApiService(HttpClient httpClient, IMemoryCache cache)
    {
        _httpClient = httpClient;
        _cache = cache;
    }

    private async Task<object?> GetFromApiAndCacheAsync(string endpoint, string cacheKey)
    {
        if (_cache.TryGetValue(cacheKey, out object? cachedData))
        {
            return cachedData;
        }

        int maxRetries = 2;
        for (int i = 0; i <= maxRetries; i++)
        {
            try
            {
                var response = await _httpClient.GetAsync(endpoint);
                response.EnsureSuccessStatusCode();

                var data = await response.Content.ReadFromJsonAsync<object>();
                if (data != null)
                {
                    _cache.Set(cacheKey, data, TimeSpan.FromMinutes(10));
                }

                return data;
            }
            catch (HttpRequestException ex)
            {
                if (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
                {
                    return null; // Don't retry on 404
                }

                if (i >= maxRetries)
                {
                    return null; // Return null after max retries instead of throwing 500
                }

                await Task.Delay(1000 * (i + 1)); // Backoff
            }
        }

        return null;
    }

    public async Task<object?> GetSurahDetailsAsync(int surahId)
    {
        return await GetFromApiAndCacheAsync($"surah/{surahId}", $"OpenApi_Surah_{surahId}");
    }

    public async Task<object?> GetVerseDetailAsync(int surahId, int ayahId)
    {
        return await GetFromApiAndCacheAsync($"surah/{surahId}/verse/{ayahId}", $"OpenApi_Verse_{surahId}_{ayahId}");
    }

    public async Task<object?> GetVerseTranslationsAsync(int surahId, int ayahId)
    {
        return await GetFromApiAndCacheAsync($"surah/{surahId}/verse/{ayahId}/translations", $"OpenApi_Translations_{surahId}_{ayahId}");
    }

    public async Task<object?> GetVersePartsAsync(int surahId, int ayahId)
    {
        return await GetFromApiAndCacheAsync($"surah/{surahId}/verse/{ayahId}/verseparts", $"OpenApi_VerseParts_{surahId}_{ayahId}");
    }

    public async Task<object?> GetRootDetailsAsync(string latin)
    {
        return await GetFromApiAndCacheAsync($"root/latin/{latin}", $"OpenApi_Root_{latin}");
    }

    public async Task<object?> GetRootVersePartsAsync(string latin)
    {
        return await GetFromApiAndCacheAsync($"root/latin/{latin}/verseparts", $"OpenApi_RootVerseParts_{latin}");
    }

    public async Task<object?> GetPageVersesAsync(int pageNumber)
    {
        return await GetFromApiAndCacheAsync($"page/{pageNumber}", $"OpenApi_Page_{pageNumber}");
    }
}
