namespace Application.Dashboard.Dtos;

public class DashboardLayoutDto
{
    public string[] WidgetsOrder { get; set; } = Array.Empty<string>();
    public IDictionary<string, bool> Visible { get; set; } = new Dictionary<string, bool>();
    public IDictionary<string, object> Size { get; set; } = new Dictionary<string, object>();
    public IDictionary<string, bool> AutoRefresh { get; set; } = new Dictionary<string, bool>();
    public IDictionary<string, int> AutoRefreshInterval { get; set; } = new Dictionary<string, int>();
}
