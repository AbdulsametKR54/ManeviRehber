using FluentValidation;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Text.Json;

namespace Api.Middleware;

public class ExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IWebHostEnvironment _env;
    private readonly ILogger<ExceptionMiddleware> _logger;

    public ExceptionMiddleware(RequestDelegate next, IWebHostEnvironment env, ILogger<ExceptionMiddleware> logger)
    {
        _next = next;
        _env = env;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (ValidationException ex)
        {
            context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
            context.Response.ContentType = "application/json";

            var errors = ex.Errors
                .GroupBy(e => e.PropertyName)
                .ToDictionary(
                    g => g.Key,
                    g => g.Select(e => e.ErrorMessage).ToArray()
                );

            var json = JsonSerializer.Serialize(new { errors });

            await context.Response.WriteAsync(json);
        }
        catch (Application.Common.Exceptions.NotFoundException ex)
        {
            context.Response.StatusCode = (int)HttpStatusCode.NotFound;
            context.Response.ContentType = "application/json";
            
            var result = JsonSerializer.Serialize(new { error = ex.Message });
            
            await context.Response.WriteAsync(result);
        }
        catch (DbUpdateException ex)
        {
            _logger.LogError(ex, "Veritabanı güncelleme hatası");
            
            context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
            context.Response.ContentType = "application/json";

            var message = _env.IsDevelopment() ? ex.InnerException?.Message ?? ex.Message : "Veritabanı işlemi sırasında bir hata oluştu.";
            var result = JsonSerializer.Serialize(new { error = message });
            
            await context.Response.WriteAsync(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Beklenmeyen bir hata oluştu");
            
            context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
            context.Response.ContentType = "application/json";

            var message = _env.IsDevelopment() ? ex.Message : "Sunucu tarafında bir hata oluştu.";
            var stackTrace = _env.IsDevelopment() ? ex.StackTrace : null;
            
            var result = JsonSerializer.Serialize(new { error = message, stackTrace });
            
            await context.Response.WriteAsync(result);
        }
    }
}