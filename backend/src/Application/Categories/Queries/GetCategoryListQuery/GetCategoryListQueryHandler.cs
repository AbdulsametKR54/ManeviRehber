using Application.Common.DTOs.Categories;
using Application.Common.Interfaces;
using Domain.Entities;
using MediatR;
using System.Linq;

namespace Application.Categories.Queries.GetCategoryList;

public class GetCategoryListQueryHandler : IRequestHandler<GetCategoryListQuery, List<CategoryDto>>
{
    private readonly ICategoryRepository _repository;

    public GetCategoryListQueryHandler(ICategoryRepository repository)
    {
        _repository = repository;
    }

    public async Task<List<CategoryDto>> Handle(GetCategoryListQuery request, CancellationToken cancellationToken)
    {
        var entities = await _repository.GetAllAsync();
        return entities.Select(x => new CategoryDto
        {
            Id = x.Id,
            Name = x.Name ?? string.Empty,
            Description = x.Description ?? string.Empty
        }).ToList();
    }
}