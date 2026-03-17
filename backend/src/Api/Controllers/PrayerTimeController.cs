using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Application.PrayerTimes.Commands.CreatePrayerTime; 
using Application.PrayerTimes.Queries.GetPrayerTimeByDate; 
using Application.PrayerTimes.Queries.GetMonthlyPrayerTimes;
using Microsoft.AspNetCore.Authorization;

namespace Api.Controllers
{   
    [Authorize(Roles = "Admin")]
    [ApiController]
    [Route("api/[controller]")]
    public class PrayerTimeController : ControllerBase
    {
        private readonly IMediator _mediator;

        public PrayerTimeController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpPost]
        public async Task<IActionResult> Create (CreatePrayerTimeCommand command)
        {
            var id = await _mediator.Send(command);
            return Ok(new { Id = id });
        }

        [HttpGet("daily/{locationId}/{date}")]
        public async Task<IActionResult> GetByDate(int locationId, DateOnly date)
        {
            var result = await _mediator.Send(new GetPrayerTimeByDateQuery(locationId, date));

            if (result == null)
                return NotFound("Bu tarih için namaz vakti bulunamadı.");

            return Ok(result);
        }

        [HttpGet("monthly/{locationId}/{year}/{month}")]
        public async Task<IActionResult> GetMonthly(int locationId, int year, int month)
        {
            var result = await _mediator.Send(
                new GetMonthlyPrayerTimesQuery(locationId, year, month)
            );

            return Ok(result); // Liste boşsa bile 200 döner
        }

    }
}