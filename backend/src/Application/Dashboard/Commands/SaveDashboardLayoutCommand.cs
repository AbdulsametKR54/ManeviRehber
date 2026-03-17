using Application.Common.Interfaces;
using Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace Application.Dashboard.Commands;

public class SaveDashboardLayoutCommand : IRequest<Unit>
{
    public string[] WidgetsOrder { get; set; } = Array.Empty<string>();
    public IDictionary<string, bool> Visible { get; set; } = new Dictionary<string, bool>();
    public IDictionary<string, object> Size { get; set; } = new Dictionary<string, object>();
    public IDictionary<string, bool> AutoRefresh { get; set; } = new Dictionary<string, bool>();
    public IDictionary<string, int> AutoRefreshInterval { get; set; } = new Dictionary<string, int>();
}

public class SaveDashboardLayoutCommandHandler : IRequestHandler<SaveDashboardLayoutCommand, Unit>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUserService;

    public SaveDashboardLayoutCommandHandler(IApplicationDbContext context, ICurrentUserService currentUserService)
    {
        _context = context;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(SaveDashboardLayoutCommand request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId ?? throw new UnauthorizedAccessException();

        var layout = await _context.UserDashboardLayouts
            .FirstOrDefaultAsync(x => x.UserId == userId, cancellationToken);

        if (layout == null)
        {
            layout = new UserDashboardLayout(userId);
            _context.UserDashboardLayouts.Add(layout);
        }

        layout.UpdateLayout(
            JsonSerializer.Serialize(request.WidgetsOrder),
            JsonSerializer.Serialize(request.Visible),
            JsonSerializer.Serialize(request.Size),
            JsonSerializer.Serialize(request.AutoRefresh),
            JsonSerializer.Serialize(request.AutoRefreshInterval)
        );

        await _context.SaveChangesAsync(cancellationToken);

        return Unit.Value;
    }
}
