using Application.Common.DTOs.Quran;
using Application.Common.DTOs.Quran.OpenApi;

namespace Application.Common.Interfaces;

public interface IQuranService : IQuranInternalService, IQuranOpenApiService
{
    Task<AyahDto> GetRandomVerseAsync();
}
