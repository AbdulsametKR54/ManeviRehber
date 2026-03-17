using System.Threading;
using System.Threading.Tasks;
using Application.Common.DTOs.Settings;
using Application.Common.Interfaces;
using MediatR;

namespace Application.Settings.Queries.GetSettingById;

public class GetSettingByIdQueryHandler : IRequestHandler<GetSettingByIdQuery, SettingDto?>
{
    private readonly ISettingRepository _repository;

    public GetSettingByIdQueryHandler(ISettingRepository repository)
    {
        _repository = repository;
    }

    public async Task<SettingDto?> Handle(GetSettingByIdQuery request, CancellationToken cancellationToken)
    {
        var entity = await _repository.GetByIdAsync(request.Id);

        if (entity == null)
            return null;

        return new SettingDto
        {
            Id = entity.Id,
            Key = entity.Key,
            Value = entity.Value,
            Description = entity.Description
        };
    }
}
