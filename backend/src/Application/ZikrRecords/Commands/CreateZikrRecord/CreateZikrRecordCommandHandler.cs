using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.ZikrRecords.Commands.CreateZikrRecord;

public class CreateZikrRecordCommandHandler : IRequestHandler<CreateZikrRecordCommand, Guid>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUserService;

    public CreateZikrRecordCommandHandler(IApplicationDbContext context, ICurrentUserService currentUserService)
    {
        _context = context;
        _currentUserService = currentUserService;
    }

    public async Task<Guid> Handle(CreateZikrRecordCommand request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId ?? throw new UnauthorizedAccessException("Giriş yapmanız gerekiyor.");

        // Check if there is already a record for this userId, phrase and date.
        // If so, update it. If not, create a new one.
        // Note: The user said "Id, UserId, Kelime, Sayı, Tarih". 
        // Typically zikirmatik saves are increments, so we might want to sum or replace.
        // User request says "POST /api/zikr { phrase, count, date }". 
        // I will implement it so it adds to existing if date matches, or replaces if that's preferred.
        // Let's go with "Upsert" for the specific date/phrase.
        
        var existing = await _context.ZikrRecords
            .FirstOrDefaultAsync(x => x.UserId == userId && x.Phrase == request.Phrase && x.Date == request.Date, cancellationToken);

        if (existing != null)
        {
            existing.UpdateCount(request.Count);
            await _context.SaveChangesAsync(cancellationToken);
            return existing.Id;
        }
        else
        {
            var record = new ZikrRecord(userId, request.Phrase, request.Count, request.Date);
            _context.ZikrRecords.Add(record);
            await _context.SaveChangesAsync(cancellationToken);
            return record.Id;
        }
    }
}
