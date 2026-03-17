using Application.Common.DTOs.Quran;
using Application.Common.Interfaces;

namespace Infrastructure.Repositories;

public class QuranRepository : IQuranRepository
{
    private static readonly List<SurahDto> Surahs = new()
    {
        new SurahDto { Id = 1, Name = "Fatiha", TurkishName = "Fatiha", AyahCount = 7 },
        new SurahDto { Id = 2, Name = "Bakara", TurkishName = "Bakara", AyahCount = 286 },
        new SurahDto { Id = 3, Name = "Al-i İmran", TurkishName = "Al-i İmran", AyahCount = 200 },
        new SurahDto { Id = 4, Name = "Nisa", TurkishName = "Nisâ", AyahCount = 176 },
        new SurahDto { Id = 5, Name = "Maide", TurkishName = "Mâide", AyahCount = 120 },
        new SurahDto { Id = 6, Name = "En'am", TurkishName = "En'âm", AyahCount = 165 },
        new SurahDto { Id = 7, Name = "A'raf", TurkishName = "A'râf", AyahCount = 206 },
        new SurahDto { Id = 8, Name = "Enfal", TurkishName = "Enfâl", AyahCount = 75 },
        new SurahDto { Id = 9, Name = "Tevbe", TurkishName = "Tevbe", AyahCount = 129 },
        new SurahDto { Id = 10, Name = "Yunus", TurkishName = "Yûnus", AyahCount = 109 },
        new SurahDto { Id = 11, Name = "Hud", TurkishName = "Hûd", AyahCount = 123 },
        new SurahDto { Id = 12, Name = "Yusuf", TurkishName = "Yûsuf", AyahCount = 111 },
        new SurahDto { Id = 13, Name = "Ra'd", TurkishName = "Ra'd", AyahCount = 43 },
        new SurahDto { Id = 14, Name = "İbrahim", TurkishName = "İbrâhim", AyahCount = 52 },
        new SurahDto { Id = 15, Name = "Hicr", TurkishName = "Hicr", AyahCount = 99 },
        new SurahDto { Id = 16, Name = "Nahl", TurkishName = "Nahl", AyahCount = 128 },
        new SurahDto { Id = 17, Name = "İsra", TurkishName = "İsrâ", AyahCount = 111 },
        new SurahDto { Id = 18, Name = "Kehf", TurkishName = "Kehf", AyahCount = 110 },
        new SurahDto { Id = 19, Name = "Meryem", TurkishName = "Meryem", AyahCount = 98 },
        new SurahDto { Id = 20, Name = "Taha", TurkishName = "Tâhâ", AyahCount = 135 },
        new SurahDto { Id = 21, Name = "Enbiya", TurkishName = "Enbiyâ", AyahCount = 112 },
        new SurahDto { Id = 22, Name = "Hac", TurkishName = "Hac", AyahCount = 78 },
        new SurahDto { Id = 23, Name = "Mü'minun", TurkishName = "Mü'minûn", AyahCount = 118 },
        new SurahDto { Id = 24, Name = "Nur", TurkishName = "Nûr", AyahCount = 64 },
        new SurahDto { Id = 25, Name = "Furkan", TurkishName = "Furkân", AyahCount = 77 },
        new SurahDto { Id = 26, Name = "Şuara", TurkishName = "Şuarâ", AyahCount = 227 },
        new SurahDto { Id = 27, Name = "Neml", TurkishName = "Neml", AyahCount = 93 },
        new SurahDto { Id = 28, Name = "Kasas", TurkishName = "Kasas", AyahCount = 88 },
        new SurahDto { Id = 29, Name = "Ankebut", TurkishName = "Ankebût", AyahCount = 69 },
        new SurahDto { Id = 30, Name = "Rum", TurkishName = "Rûm", AyahCount = 60 },
        new SurahDto { Id = 31, Name = "Lokman", TurkishName = "Lokmân", AyahCount = 34 },
        new SurahDto { Id = 32, Name = "Secde", TurkishName = "Secde", AyahCount = 30 },
        new SurahDto { Id = 33, Name = "Ahzab", TurkishName = "Ahzâb", AyahCount = 73 },
        new SurahDto { Id = 34, Name = "Sebe", TurkishName = "Sebe'", AyahCount = 54 },
        new SurahDto { Id = 35, Name = "Fatır", TurkishName = "Fâtır", AyahCount = 45 },
        new SurahDto { Id = 36, Name = "Yasin", TurkishName = "Yâsîn", AyahCount = 83 },
        new SurahDto { Id = 37, Name = "Saffat", TurkishName = "Sâffât", AyahCount = 182 },
        new SurahDto { Id = 38, Name = "Sad", TurkishName = "Sâd", AyahCount = 88 },
        new SurahDto { Id = 39, Name = "Zümer", TurkishName = "Zümer", AyahCount = 75 },
        new SurahDto { Id = 40, Name = "Mü'min", TurkishName = "Mü'min", AyahCount = 85 },
        new SurahDto { Id = 41, Name = "Fussilet", TurkishName = "Fussilet", AyahCount = 54 },
        new SurahDto { Id = 42, Name = "Şura", TurkishName = "Şûrâ", AyahCount = 53 },
        new SurahDto { Id = 43, Name = "Zuhruf", TurkishName = "Zuhruf", AyahCount = 89 },
        new SurahDto { Id = 44, Name = "Duhan", TurkishName = "Duhân", AyahCount = 59 },
        new SurahDto { Id = 45, Name = "Casiye", TurkishName = "Câsiye", AyahCount = 37 },
        new SurahDto { Id = 46, Name = "Ahkaf", TurkishName = "Ahkâf", AyahCount = 35 },
        new SurahDto { Id = 47, Name = "Muhammed", TurkishName = "Muhammed", AyahCount = 38 },
        new SurahDto { Id = 48, Name = "Fetih", TurkishName = "Fetih", AyahCount = 29 },
        new SurahDto { Id = 49, Name = "Hucurat", TurkishName = "Hucurât", AyahCount = 18 },
        new SurahDto { Id = 50, Name = "Kaf", TurkishName = "Kâf", AyahCount = 45 },
        new SurahDto { Id = 51, Name = "Zariyat", TurkishName = "Zâriyât", AyahCount = 60 },
        new SurahDto { Id = 52, Name = "Tur", TurkishName = "Tûr", AyahCount = 49 },
        new SurahDto { Id = 53, Name = "Necm", TurkishName = "Necm", AyahCount = 62 },
        new SurahDto { Id = 54, Name = "Kamer", TurkishName = "Kamer", AyahCount = 55 },
        new SurahDto { Id = 55, Name = "Rahman", TurkishName = "Rahmân", AyahCount = 78 },
        new SurahDto { Id = 56, Name = "Vakia", TurkishName = "Vâkıa", AyahCount = 96 },
        new SurahDto { Id = 57, Name = "Hadid", TurkishName = "Hadîd", AyahCount = 29 },
        new SurahDto { Id = 58, Name = "Mücadele", TurkishName = "Mücâdele", AyahCount = 22 },
        new SurahDto { Id = 59, Name = "Haşr", TurkishName = "Haşr", AyahCount = 24 },
        new SurahDto { Id = 60, Name = "Mümtehine", TurkishName = "Mümtehine", AyahCount = 13 },
        new SurahDto { Id = 61, Name = "Saff", TurkishName = "Saff", AyahCount = 14 },
        new SurahDto { Id = 62, Name = "Cuma", TurkishName = "Cuma", AyahCount = 11 },
        new SurahDto { Id = 63, Name = "Münafıkun", TurkishName = "Münafıkûn", AyahCount = 11 },
        new SurahDto { Id = 64, Name = "Tegabun", TurkishName = "Tegâbun", AyahCount = 18 },
        new SurahDto { Id = 65, Name = "Talak", TurkishName = "Talâk", AyahCount = 12 },
        new SurahDto { Id = 66, Name = "Tahrim", TurkishName = "Tahrîm", AyahCount = 12 },
        new SurahDto { Id = 67, Name = "Mülk", TurkishName = "Mülk", AyahCount = 30 },
        new SurahDto { Id = 68, Name = "Kalem", TurkishName = "Kalem", AyahCount = 52 },
        new SurahDto { Id = 69, Name = "Hakka", TurkishName = "Hâkka", AyahCount = 52 },
        new SurahDto { Id = 70, Name = "Mearic", TurkishName = "Meâric", AyahCount = 44 },
        new SurahDto { Id = 71, Name = "Nuh", TurkishName = "Nûh", AyahCount = 28 },
        new SurahDto { Id = 72, Name = "Cin", TurkishName = "Cin", AyahCount = 28 },
        new SurahDto { Id = 73, Name = "Müzzemmil", TurkishName = "Müzzemmil", AyahCount = 20 },
        new SurahDto { Id = 74, Name = "Müddessir", TurkishName = "Müddessir", AyahCount = 56 },
        new SurahDto { Id = 75, Name = "Kıyamet", TurkishName = "Kıyâmet", AyahCount = 40 },
        new SurahDto { Id = 76, Name = "İnsan", TurkishName = "İnsan", AyahCount = 31 },
        new SurahDto { Id = 77, Name = "Mürselat", TurkishName = "Mürselât", AyahCount = 50 },
        new SurahDto { Id = 78, Name = "Nebe", TurkishName = "Nebe'", AyahCount = 40 },
        new SurahDto { Id = 79, Name = "Naziat", TurkishName = "Nâziât", AyahCount = 46 },
        new SurahDto { Id = 80, Name = "Abese", TurkishName = "Abese", AyahCount = 42 },
        new SurahDto { Id = 81, Name = "Tekvir", TurkishName = "Tekvîr", AyahCount = 29 },
        new SurahDto { Id = 82, Name = "İnfitar", TurkishName = "İnfitâr", AyahCount = 19 },
        new SurahDto { Id = 83, Name = "Mutaffifin", TurkishName = "Mutaffifîn", AyahCount = 36 },
        new SurahDto { Id = 84, Name = "İnşikak", TurkishName = "İnşikâk", AyahCount = 25 },
        new SurahDto { Id = 85, Name = "Buruc", TurkishName = "Burûc", AyahCount = 22 },
        new SurahDto { Id = 86, Name = "Tarık", TurkishName = "Târık", AyahCount = 17 },
        new SurahDto { Id = 87, Name = "A'la", TurkishName = "A'lâ", AyahCount = 19 },
        new SurahDto { Id = 88, Name = "Gaşiye", TurkishName = "Gâşiye", AyahCount = 26 },
        new SurahDto { Id = 89, Name = "Fecr", TurkishName = "Fecr", AyahCount = 30 },
        new SurahDto { Id = 90, Name = "Beled", TurkishName = "Beled", AyahCount = 20 },
        new SurahDto { Id = 91, Name = "Şems", TurkishName = "Şems", AyahCount = 15 },
        new SurahDto { Id = 92, Name = "Leyl", TurkishName = "Leyl", AyahCount = 21 },
        new SurahDto { Id = 93, Name = "Duha", TurkishName = "Duhâ", AyahCount = 11 },
        new SurahDto { Id = 94, Name = "İnşirah", TurkishName = "İnşirah", AyahCount = 8 },
        new SurahDto { Id = 95, Name = "Tin", TurkishName = "Tîn", AyahCount = 8 },
        new SurahDto { Id = 96, Name = "Alak", TurkishName = "Alak", AyahCount = 19 },
        new SurahDto { Id = 97, Name = "Kadir", TurkishName = "Kadir", AyahCount = 5 },
        new SurahDto { Id = 98, Name = "Beyyine", TurkishName = "Beyyine", AyahCount = 8 },
        new SurahDto { Id = 99, Name = "Zilzal", TurkishName = "Zilzâl", AyahCount = 8 },
        new SurahDto { Id = 100, Name = "Adiyat", TurkishName = "Adiyât", AyahCount = 11 },
        new SurahDto { Id = 101, Name = "Karia", TurkishName = "Kâria", AyahCount = 11 },
        new SurahDto { Id = 102, Name = "Tekasür", TurkishName = "Tekasür", AyahCount = 8 },
        new SurahDto { Id = 103, Name = "Asr", TurkishName = "Asr", AyahCount = 3 },
        new SurahDto { Id = 104, Name = "Hümeze", TurkishName = "Hümeze", AyahCount = 9 },
        new SurahDto { Id = 105, Name = "Fil", TurkishName = "Fîl", AyahCount = 5 },
        new SurahDto { Id = 106, Name = "Kureyş", TurkishName = "Kureyş", AyahCount = 4 },
        new SurahDto { Id = 107, Name = "Maun", TurkishName = "Mâûn", AyahCount = 7 },
        new SurahDto { Id = 108, Name = "Kevser", TurkishName = "Kevser", AyahCount = 3 },
        new SurahDto { Id = 109, Name = "Kafirun", TurkishName = "Kâfirûn", AyahCount = 6 },
        new SurahDto { Id = 110, Name = "Nasr", TurkishName = "Nasr", AyahCount = 3 },
        new SurahDto { Id = 111, Name = "Tebbet", TurkishName = "Tebbet", AyahCount = 5 },
        new SurahDto { Id = 112, Name = "İhlas", TurkishName = "İhlâs", AyahCount = 4 },
        new SurahDto { Id = 113, Name = "Felak", TurkishName = "Felak", AyahCount = 5 },
        new SurahDto { Id = 114, Name = "Nas", TurkishName = "Nâs", AyahCount = 6 }
    };

    public Task<List<SurahDto>> GetSurahsAsync()
    {
        return Task.FromResult(Surahs);
    }

    public Task<List<ReciterDto>> GetRecitersAsync()
    {
        var reciters = new List<ReciterDto>();
        var basePath = @"C:\Users\Abdulsamet KIR\Desktop\Kuran\Sesler";

        if (Directory.Exists(basePath))
        {
            var directories = Directory.GetDirectories(basePath);
            foreach (var dir in directories)
            {
                var dirName = Path.GetFileName(dir);
                reciters.Add(new ReciterDto
                {
                    Id = dirName,
                    Name = dirName.Replace("_", " ")
                });
            }
        }

        return Task.FromResult(reciters);
    }

    public Task<List<AyahDto>> GetAyahsBySurahIdAsync(int surahId)
    {
        var surah = Surahs.FirstOrDefault(s => s.Id == surahId);
        if (surah == null) return Task.FromResult(new List<AyahDto>());

        var ayahs = new List<AyahDto>();
        for (int i = 1; i <= surah.AyahCount; i++)
        {
            ayahs.Add(new AyahDto
            {
                Id = (surahId * 1000) + i,
                SurahId = surahId,
                AyahNumber = i,
                Text = $"[Arapça Metin Placeholder for {surahId}:{i}]",
                Juz = 1, // Placeholder
                Page = 1  // Placeholder
            });
        }
        return Task.FromResult(ayahs);
    }

    public Task<List<string>> GetAyahImagesAsync(int surahId, int ayahId)
    {
        var surahStr = surahId.ToString("000");
        var basePath = Path.Combine(@"C:\Users\Abdulsamet KIR\Desktop\Kuran\Gorseller", surahStr);
        
        var images = new List<string>();
        if (Directory.Exists(basePath))
        {
            // Pattern 1: {surah}_{ayah}.png
            var exactFileName = $"{surahId}_{ayahId}.png";
            var exactFilePath = Path.Combine(basePath, exactFileName);
            if (File.Exists(exactFilePath))
            {
                images.Add($"/Gorseller/{surahStr}/{exactFileName}");
            }

            // Pattern 2: {surah}_{ayah}_*.png (for split ayahs)
            var parts = Directory.GetFiles(basePath, $"{surahId}_{ayahId}_*.png")
                                 .OrderBy(f => f);
            
            foreach (var part in parts)
            {
                var partName = Path.GetFileName(part);
                var url = $"/Gorseller/{surahStr}/{partName}";
                if (!images.Contains(url))
                {
                    images.Add(url);
                }
            }
        }
        
        return Task.FromResult(images);
    }

    public Task<string> GetAyahAudioPathAsync(string reciter, int surahId, int ayahId)
    {
        // Simulation of audio path
        // pattern: {reciter}/{surah:D3}{ayah:D3}.mp3
        var audioPath = $"{reciter}/{surahId:D3}{ayahId:D3}.mp3";
        return Task.FromResult(audioPath);
    }
}
