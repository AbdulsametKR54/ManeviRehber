using MediatR;
using Application.Common.Interfaces;
using Domain.Entities;
using Newtonsoft.Json;

namespace Application.PrayerTimes.Commands.CreatePrayerTime;

public class CreatePrayerTimeCommandHandler 
    : IRequestHandler<CreatePrayerTimeCommand, Guid>
{
    private readonly IApplicationDbContext _context;
    private readonly IPrayerTimeRepository _repository;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public CreatePrayerTimeCommandHandler(
        IApplicationDbContext context,
        IPrayerTimeRepository repository,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _context = context;
        _repository = repository;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Guid> Handle(CreatePrayerTimeCommand request, CancellationToken cancellationToken)
    {
        // Repository üzerinden kontrol
        var exists = await _repository.ExistsAsync(
            request.LocationId,
            request.Date,
            cancellationToken
        );

        if (exists)
            throw new InvalidOperationException("Bu lokasyon ve tarihe ait namaz vakitleri zaten mevcut.");

        // Yeni entity oluştur
        var entity = new PrayerTime(
            request.LocationId,
            request.Date,
            request.Fajr,
            request.Sunrise,
            request.Dhuhr,
            request.Asr,
            request.Maghrib,
            request.Sunset,
            request.Isha,
            request.HijriDateLong
        );

        // Repository üzerinden ekle
        await _repository.AddAsync(entity, cancellationToken);

        // SaveChanges yine DbContext üzerinden
        await _context.SaveChangesAsync(cancellationToken);

        await _logRepository.AddAsync(new Log(
            _currentUserService.UserId ?? Guid.Empty,
            "PrayerTime.Create",
            $"Created PrayerTime {entity.Id} for Location {entity.LocationId}",
            JsonConvert.SerializeObject(new { New = entity }),
            _currentUserService.IpAddress
        ));

        return entity.Id;
    }
}
