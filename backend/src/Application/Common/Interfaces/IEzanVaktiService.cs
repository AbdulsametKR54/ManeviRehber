using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Application.Common.DTOs;
using Application.PrayerTimes.Queries.GetPrayerTimeByDate;
namespace Application.Common.Interfaces
{
    public interface IEzanVaktiService
    {
        Task<List<ExternalPrayerTimeDto>> GetPrayerTimesAsync(int districtId);
        
        Task<List<CountryDto>> GetCountriesAsync();
        Task<List<CityDto>> GetCitiesAsync(int countryId);
        Task<List<DistrictDto>> GetDistrictsAsync(int cityId);
    }

}