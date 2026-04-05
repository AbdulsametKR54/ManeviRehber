namespace Application.Common.DTOs.Quran.OpenApi;

public class OpenApiResponse<T>
{
    public T? Data { get; set; }
}

public class VerseDetailDto
{
    public int Id { get; set; }
    public int SurahId { get; set; }
    public int VerseNumber { get; set; }
    public string Verse { get; set; } = string.Empty;
    public string Transcription { get; set; } = string.Empty;
    public TranslationDto? Translation { get; set; }
}

public class TranslationDto
{
    public int Id { get; set; }
    public AuthorDto? Author { get; set; }
    public string Text { get; set; } = string.Empty;
}

public class AuthorDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Language { get; set; } = string.Empty;
}

public class VersePartDto
{
    public int Id { get; set; }
    public string Word { get; set; } = string.Empty;
    public string Translation { get; set; } = string.Empty;
    public string Root { get; set; } = string.Empty;
    public string RootContext { get; set; } = string.Empty;
}

public class RootDto
{
    public string Arabic { get; set; } = string.Empty;
    public string Latin { get; set; } = string.Empty;
}

public class PageDto
{
    public int Id { get; set; }
    public List<VerseDetailDto> Verses { get; set; } = new();
}
