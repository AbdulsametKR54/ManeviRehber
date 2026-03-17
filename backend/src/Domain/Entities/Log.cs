using System;
using Domain.Common;

namespace Domain.Entities;

public class Log : BaseEntity, IAggregateRoot
{
    // The ID of the User (Admin) who performed the action
    public Guid UserId { get; private set; }

    // Action Name (e.g., "DailyContent.Update")
    public string Action { get; private set; }

    // Short summary (e.g., "Updated DailyContent XYZ")
    public string Description { get; private set; }

    // Old and New Values serialized as JSON
    public string Data { get; private set; }

    // IP address of the user making the request
    public string IpAddress { get; private set; }

    private Log() { } // EF Core için gerekli

    public Log(Guid userId, string action, string description, string data, string ipAddress)
    {
        if (string.IsNullOrWhiteSpace(action))
            throw new ArgumentException("Action cannot be empty");

        UserId = userId;
        Action = action;
        Description = description ?? string.Empty;
        Data = data ?? string.Empty;
        IpAddress = ipAddress ?? string.Empty;
    }
}
