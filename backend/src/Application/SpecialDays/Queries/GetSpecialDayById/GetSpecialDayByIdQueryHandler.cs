using System.Threading;
using System.Threading.Tasks;
using Application.Common.DTOs.SpecialDays;
using Application.Common.Interfaces;
using MediatR;

namespace Application.SpecialDays.Queries.GetSpecialDayById;

public class GetSpecialDayByIdQueryHandler : IRequestHandler<GetSpecialDayByIdQuery, SpecialDayDto?>
{
    private readonly ISpecialDayRepository _repository;

    public GetSpecialDayByIdQueryHandler(ISpecialDayRepository repository)
    {
        _repository = repository;
    }

    public async Task<SpecialDayDto?> Handle(GetSpecialDayByIdQuery request, CancellationToken cancellationToken)
    {
        var entity = await _repository.GetByIdAsync(request.Id);

        if (entity == null)
            return null;

        return new SpecialDayDto
        {
            Id = entity.Id,
            Name = entity.Name,
            Date = entity.Date,
            Description = entity.Description
        };
    }
}
