using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Application.Common.Exceptions;
using Domain.Entities;
using MediatR;
using Newtonsoft.Json;

namespace Application.DailyContents.Commands.CreateDailyContent;

public class CreateDailyContentCommandHandler : IRequestHandler<CreateDailyContentCommand, Guid>
{
    private readonly IApplicationDbContext _context;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly ICategoryRepository _categoryRepository;
    private readonly ISpecialDayRepository _specialDayRepository;

    public CreateDailyContentCommandHandler(
        IApplicationDbContext context, 
        ILogRepository logRepository, 
        ICurrentUserService currentUserService,
        ICategoryRepository categoryRepository,
        ISpecialDayRepository specialDayRepository)
    {
        _context = context;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
        _categoryRepository = categoryRepository;
        _specialDayRepository = specialDayRepository;
    }

    public async Task<Guid> Handle(CreateDailyContentCommand request, CancellationToken cancellationToken)
    {
        if (request.CategoryIds == null)
            request.CategoryIds = new List<Guid>();

        if (request.SpecialDayId.HasValue)
        {
            var specialDay = await _specialDayRepository.GetByIdAsync(request.SpecialDayId.Value);
            if (specialDay == null)
            {
                throw new NotFoundException(nameof(SpecialDay), request.SpecialDayId.Value);
            }
        }

        foreach (var categoryId in request.CategoryIds)
        {
            var category = await _categoryRepository.GetByIdAsync(categoryId);
            if (category == null)
            {
                throw new NotFoundException(nameof(Category), categoryId);
            }
        }

        var entity = new DailyContent(request.Title, request.Content, request.Type, request.Date, request.SpecialDayId);

        _context.DailyContents.Add(entity);
        await _context.SaveChangesAsync(cancellationToken);

        if (request.CategoryIds.Count > 0)
        {
            await _context.DailyContentCategories.AddRangeAsync(
                request.CategoryIds.Select(id => new DailyContentCategory
                {
                    DailyContentId = entity.Id,
                    CategoryId = id
                })
            );
            await _context.SaveChangesAsync(cancellationToken);
        }

        await _logRepository.AddAsync(new Log(
            _currentUserService.UserId ?? Guid.Empty,
            "DailyContent.Create",
            $"Created DailyContent {entity.Id}",
            JsonConvert.SerializeObject(new { New = entity }, new JsonSerializerSettings { ReferenceLoopHandling = ReferenceLoopHandling.Ignore }),
            _currentUserService.IpAddress
        ));

        return entity.Id;
    }
}
