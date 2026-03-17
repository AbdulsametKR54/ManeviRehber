using System.Threading;
using System.Threading.Tasks;
using Application.Common.DTOs.Categories;
using Application.Common.Interfaces;
using MediatR;

namespace Application.Categories.Queries.GetCategoryByIdQuery;

public class GetCategoryByIdQueryHandler : IRequestHandler<GetCategoryByIdQuery, CategoryDto?>
{
    private readonly ICategoryRepository _repository;

    public GetCategoryByIdQueryHandler(ICategoryRepository repository)
    {
        _repository = repository;
    }

    public async Task<CategoryDto?> Handle(GetCategoryByIdQuery request, CancellationToken cancellationToken)
    {
        var entity = await _repository.GetByIdAsync(request.Id);

        if (entity == null)
            return null;

        return new CategoryDto
        {
            Id = entity.Id,
            Name = entity.Name ?? string.Empty,
            Description = entity.Description ?? string.Empty
        };
    }
}
