using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using System.Net.Http.Json;
using Application.PrayerTimes.Queries.GetPrayerTimeByDate;
using Application.Common.DTOs;

namespace Infrastructure.Services;

public class EzanVaktiService : IEzanVaktiService
{
    private readonly HttpClient _http;

    public EzanVaktiService(HttpClient http)
    {
        _http = http;
    }

    public async Task<List<ExternalPrayerTimeDto>> GetPrayerTimesAsync(int districtId)
    {
        var url = $"https://ezanvakti.emushaf.net/vakitler/{districtId}";
        var result = await _http.GetFromJsonAsync<List<ExternalPrayerTimeDto>>(url);

        return result ?? new List<ExternalPrayerTimeDto>();
    }

    public async Task<List<CountryDto>> GetCountriesAsync() 
    { 
        var url = "https://ezanvakti.emushaf.net/ulkeler"; 
        return await _http.GetFromJsonAsync<List<CountryDto>>(url) ?? new List<CountryDto>(); 
    }

    public async Task<List<CityDto>> GetCitiesAsync(int countryId) 
    { 
        var url = $"https://ezanvakti.emushaf.net/sehirler/{countryId}";
        return await _http.GetFromJsonAsync<List<CityDto>>(url) ?? new List<CityDto>(); 
    } 
    
    public async Task<List<DistrictDto>> GetDistrictsAsync(int cityId) 
    { 
        var url = $"https://ezanvakti.emushaf.net/ilceler/{cityId}"; 
        return await _http.GetFromJsonAsync<List<DistrictDto>>(url) ?? new List<DistrictDto>();
    }

}
