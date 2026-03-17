using Application.Common.Interfaces;
using Domain.Entities;
using MediatR;
using Newtonsoft.Json;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Application.Categories.Commands.DeleteCategory;

public class DeleteCategoryCommandHandler : IRequestHandler<DeleteCategoryCommand>
{
    private readonly ICategoryRepository _repository;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public DeleteCategoryCommandHandler(
        ICategoryRepository repository,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _repository = repository;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteCategoryCommand request, CancellationToken cancellationToken)
    {
        var category = await _repository.GetByIdAsync(request.Id)
            ?? throw new Exception("Kategori bulunamadı.");

        await _repository.DeleteAsync(category);

        await _logRepository.AddAsync(new Log(
            _currentUserService.UserId ?? Guid.Empty,
            "Category.Delete",
            $"Deleted Category {category.Id}",
            JsonConvert.SerializeObject(new { Old = category }),
            _currentUserService.IpAddress
        ));

        return Unit.Value;
    }
}