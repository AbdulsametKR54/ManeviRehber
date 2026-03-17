using System;
using Application.Common.DTOs.Categories;
using MediatR;

namespace Application.Categories.Queries.GetCategoryByIdQuery;

public class GetCategoryByIdQuery : IRequest<CategoryDto?>
{
    public Guid Id { get; set; }
}
