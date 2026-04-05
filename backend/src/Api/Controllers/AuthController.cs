using Application.Users.Commands.RegisterUser;
using Application.Users.Commands.LoginUser;
using Application.Users.Commands.UpdateUserName;
using Application.Users.Commands.UpdateEmail;
using Application.Users.Commands.UpdateLanguage;
using Application.Users.Commands.UpdatePassword;
using Application.Common.Interfaces;
using MediatR;
using Api.Models.Users;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using System.Runtime.CompilerServices;
using System.Reflection.Metadata;

namespace Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IUserRepository _userRepository;

    public AuthController(IMediator mediator,IUserRepository userRepository)
    {
        _mediator = mediator;
        _userRepository = userRepository;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody]RegisterUserCommand command)
    {
        var userId = await _mediator.Send(command);
        return Ok(new { Id = userId });
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody]LoginUserCommand command)
    {
        LoginUserResultDto user = await _mediator.Send(command);
        return Ok( user );
    }

    [Authorize]
    [HttpGet("me")]
    public IActionResult Me()
    {   
        var userId = User.FindFirst("sub")?.Value;
        var email = User.FindFirst("email")?.Value;
        var name = User.FindFirst("name")?.Value;
        var language = User.FindFirst("language")?.Value;

        return Ok(new { userId, email, name, language });
    }

    [Authorize]
    [HttpGet("profile")]
    public async Task<IActionResult> Profile()
    {
        var subClaim = User.FindFirst("sub")
            ?? throw new Exception("User id claim not found");

        var userId = Guid.Parse(subClaim.Value);

        var user = await _userRepository.GetByIdAsync(userId);
        if (user == null) return NotFound("Kullanıcı bulunamadı.");

        return Ok(new {
            user.Id,
            Email = user.Email?.Value ?? string.Empty,
            Name = user.Name ?? string.Empty,
            Language = user.Language.ToString()
        });
    }

    [Authorize]
    [HttpPut("update-name")]
    public async Task<IActionResult> UpdateName([FromBody] UpdateUserNameRequest nameRequest)
    {
        var userId=Guid.Parse(User.FindFirst("sub")!.Value);
        await _mediator.Send(new UpdateUserNameCommand(userId, nameRequest.Name));
        return Ok(new { message = "İsim başarıyla güncellendi." });
    }

    [Authorize]
    [HttpPut("update-email")]
    public async Task<IActionResult> UpdateEmail([FromBody] UpdateEmailRequest request)
    {
        var userId = Guid.Parse(User.FindFirst("sub")!.Value);

        await _mediator.Send(new UpdateEmailCommand(userId, request.Email));

        return Ok(new { message = "Email başarıyla güncellendi." });
    }

    [Authorize]
    [HttpPut("update-language")]
    public async Task<IActionResult> UpdateLanguage([FromBody] UpdateLanguageRequest request)
    {
        var userId = Guid.Parse(User.FindFirst("sub")!.Value);

        await _mediator.Send(new UpdateLanguageCommand(userId, request.Language));

        return Ok(new { message = "Dil başarıyla güncellendi." });
    }

    [Authorize]
    [HttpPut("update-password")]
    public async Task<IActionResult> UpdatePassword([FromBody] UpdatePasswordRequest request)
    {
        var userId = Guid.Parse(User.FindFirst("sub")!.Value);

        await _mediator.Send(new UpdatePasswordCommand(
            userId,
            request.OldPassword,
            request.NewPassword
        ));

        return Ok(new { message = "Şifre başarıyla güncellendi." });
    }
}