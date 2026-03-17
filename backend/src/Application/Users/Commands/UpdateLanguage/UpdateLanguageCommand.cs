using MediatR;

namespace Application.Users.Commands.UpdateLanguage;

public record UpdateLanguageCommand(Guid UserId, string language) : IRequest;