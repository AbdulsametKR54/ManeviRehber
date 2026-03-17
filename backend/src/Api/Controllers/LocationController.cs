using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Application.Common.Interfaces;

namespace Api.Controllers
{
    [ApiController]
    [Route("api/location")]
    public class LocationController : ControllerBase
    {
        private readonly IEzanVaktiService _external;

        public LocationController(IEzanVaktiService external)
        {
            _external = external;
        }

        [HttpGet("countries")]
        public async Task<IActionResult> GetCountries()
        {
            var result = await _external.GetCountriesAsync();
            return Ok(result);
        }

        [HttpGet("cities/{countryId}")]
        public async Task<IActionResult> GetCities(int countryId)
        {
            var result = await _external.GetCitiesAsync(countryId);
            return Ok(result);
        }

        [HttpGet("districts/{cityId}")]
        public async Task<IActionResult> GetDistricts(int cityId)
        {
            var result = await _external.GetDistrictsAsync(cityId);
            return Ok(result);
        }
    }

}