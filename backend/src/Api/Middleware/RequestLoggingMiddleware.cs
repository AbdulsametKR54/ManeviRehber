using Application.Common.Interfaces;
using Domain.Entities;
using Microsoft.AspNetCore.Http;
using System.Text;

namespace Api.Middleware;

public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;

    public RequestLoggingMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context, ILogRepository logRepository, ICurrentUserService currentUserService)
    {
        // Skip logging for GET requests to logs themselves or non-api requests if needed
        if (context.Request.Path.StartsWithSegments("/api/logs") || !context.Request.Path.StartsWithSegments("/api"))
        {
            await _next(context);
            return;
        }

        var request = context.Request;
        var method = request.Method;
        var path = request.Path;
        var endpoint = $"{method} {path}";
        
        // Get Platform from header
        var platform = request.Headers["X-Platform"].ToString();
        if (string.IsNullOrEmpty(platform))
        {
            var userAgent = request.Headers["User-Agent"].ToString();
            if (userAgent.Contains("Dart") || userAgent.Contains("Mobile"))
            {
                platform = "Mobile";
            }
            else
            {
                platform = "Web";
            }
        }

        string requestData = string.Empty;

        // Capture request body for state-changing requests
        if (method == "POST" || method == "PUT" || method == "PATCH" || method == "DELETE")
        {
            request.EnableBuffering();
            using var reader = new StreamReader(request.Body, Encoding.UTF8, true, 1024, true);
            requestData = await reader.ReadToEndAsync();
            request.Body.Position = 0;
        }

        // Proceed with the request
        await _next(context);

        // Log the request after it's processed (or before, but after next allows capturing status code if needed)
        // For now, we log the intent.
        
        var log = new Log(
            currentUserService.UserId,
            "Api.Request",
            $"Request to {endpoint}",
            requestData,
            currentUserService.IpAddress,
            platform,
            path
        );

        await logRepository.AddAsync(log);
    }
}
