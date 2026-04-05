using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Exceptions;
using Application.Common.Interfaces;
using Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;

namespace Application.DailyContents.Commands.UpdateDailyContent;

public class UpdateDailyContentCommandHandler : IRequestHandler<UpdateDailyContentCommand, Unit>
{
    private readonly IDailyContentRepository _repository;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly ICategoryRepository _categoryRepository;
    private readonly ISpecialDayRepository _specialDayRepository;
    private readonly IApplicationDbContext _context;

    public UpdateDailyContentCommandHandler(
        IDailyContentRepository repository,
        ILogRepository logRepository,
        ICurrentUserService currentUserService,
        ICategoryRepository categoryRepository,
        ISpecialDayRepository specialDayRepository,
        IApplicationDbContext context)
    {
        _repository = repository;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
        _categoryRepository = categoryRepository;
        _specialDayRepository = specialDayRepository;
        _context = context;
    }

    public async Task<Unit> Handle(UpdateDailyContentCommand request, CancellationToken cancellationToken)
    {
        // Use context directly to include DailyContentCategories
        var entity = await _context.DailyContents
            .Include(x => x.DailyContentCategories)
            .FirstOrDefaultAsync(x => x.Id == request.Id, cancellationToken);

        if (entity == null)
            throw new NotFoundException(nameof(DailyContent), request.Id);

        var oldEntity = new 
        {
            entity.Title,
            entity.Content,
            entity.Type,
            entity.Date,
            entity.SpecialDayId
        };

        if (request.SpecialDayId.HasValue)
        {
            var specialDay = await _specialDayRepository.GetByIdAsync(request.SpecialDayId.Value);
            if (specialDay == null)
            {
                throw new NotFoundException(nameof(SpecialDay), request.SpecialDayId.Value);
            }
        }

        if (request.CategoryIds != null && request.CategoryIds.Count > 0)
        {
            foreach (var categoryId in request.CategoryIds)
            {
                var category = await _categoryRepository.GetByIdAsync(categoryId);
                if (category == null)
                {
                    throw new NotFoundException(nameof(Category), categoryId);
                }
            }
        }

        entity.Update(request.Title, request.Content, request.Type, request.Date, request.SpecialDayId);

        // Update categories
        var existingCategories = entity.DailyContentCategories.ToList();
        var selectedCategoryIds = (request.CategoryIds ?? new List<Guid>()).Distinct().ToList();

        // Remove categories not in the request
        foreach (var existingMapping in existingCategories)
        {
            if (!selectedCategoryIds.Contains(existingMapping.CategoryId))
            {
                entity.DailyContentCategories.Remove(existingMapping);
            }
        }

        // Add new categories
        foreach (var categoryId in selectedCategoryIds)
        {
            if (!existingCategories.Any(x => x.CategoryId == categoryId))
            {
                entity.DailyContentCategories.Add(new DailyContentCategory
                {
                    CategoryId = categoryId,
                    DailyContentId = entity.Id
                });
            }
        }

        await _context.SaveChangesAsync(cancellationToken);

        await _logRepository.AddAsync(new Log(
            _currentUserService.UserId ?? Guid.Empty,
            "DailyContent.Update",
            $"Updated DailyContent {entity.Id}",
            JsonConvert.SerializeObject(new { Old = oldEntity, New = entity }, new JsonSerializerSettings { ReferenceLoopHandling = ReferenceLoopHandling.Ignore }),
            _currentUserService.IpAddress
        ));

        return Unit.Value;
    }
}
