namespace Application.Common.DTOs.Quran;

public class SurahDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string TurkishName { get; set; } = string.Empty;
    public int AyahCount { get; set; }
}

public class ReciterDto
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
}

public class AyahDto
{
    public int Id { get; set; }
    public int SurahId { get; set; }
    public int AyahNumber { get; set; }
    public string Text { get; set; } = string.Empty;
    public int Juz { get; set; }
    public int Page { get; set; }
}

public class AyahImageDto
{
    public string FilePath { get; set; } = string.Empty;
    public int Order { get; set; }
}

public class QuranTestResultDto
{
    public int SurahId { get; set; }
    public string SurahName { get; set; } = string.Empty;
    public List<string> MissingAudioAyahs { get; set; } = new();
    public List<string> MissingImageAyahs { get; set; } = new();
    public bool IsComplete => MissingAudioAyahs.Count == 0 && MissingImageAyahs.Count == 0;
}
