using Application.Common.Interfaces;
using Domain.Entities;
using MediatR;
using Newtonsoft.Json;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Application.Categories.Commands.UpdateCategory;

public class UpdateCategoryCommandHandler : IRequestHandler<UpdateCategoryCommand>
{
    private readonly ICategoryRepository _repository;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateCategoryCommandHandler(
        ICategoryRepository repository,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _repository = repository;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(UpdateCategoryCommand request, CancellationToken cancellationToken)
    {
        var category = await _repository.GetByIdAsync(request.Id)
            ?? throw new Exception("Kategori bulunamadı.");

        var oldEntity = new 
        {
            category.Name,
            category.Description
        };

        category.Update(request.Name, request.Description);

        await _repository.UpdateAsync(category);

        await _logRepository.AddAsync(new Log(
            _currentUserService.UserId ?? Guid.Empty,
            "Category.Update",
            $"Updated Category {category.Id}",
            JsonConvert.SerializeObject(new { Old = oldEntity, New = category }),
            _currentUserService.IpAddress
        ));

        return Unit.Value;
    }
}