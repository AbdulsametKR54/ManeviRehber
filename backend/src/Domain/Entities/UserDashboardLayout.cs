using System;
using Domain.Common;

namespace Domain.Entities;

public class UserDashboardLayout : BaseEntity
{
    public Guid UserId { get; private set; }
    public string WidgetsOrderJson { get; private set; } = "[]";
    public string VisibleJson { get; private set; } = "{}";
    public string SizeJson { get; private set; } = "{}";
    public string AutoRefreshJson { get; private set; } = "{}";
    public string AutoRefreshIntervalJson { get; private set; } = "{}";

    // EF Core için
    private UserDashboardLayout() { }

    public UserDashboardLayout(Guid userId)
    {
        UserId = userId;
    }

    public void UpdateLayout(string widgetsOrder, string visible, string size, string autoRefresh, string autoRefreshInterval)
    {
        WidgetsOrderJson = widgetsOrder ?? "[]";
        VisibleJson = visible ?? "{}";
        SizeJson = size ?? "{}";
        AutoRefreshJson = autoRefresh ?? "{}";
        AutoRefreshIntervalJson = autoRefreshInterval ?? "{}";
        SetUpdated();
    }
}
