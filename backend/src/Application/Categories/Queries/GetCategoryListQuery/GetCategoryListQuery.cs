using MediatR;
using System.Collections.Generic;
using Application.Common.DTOs.Categories;

namespace Application.Categories.Queries.GetCategoryList;

public record GetCategoryListQuery() : IRequest<List<CategoryDto>>;