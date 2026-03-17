"use client";

import React, { useState, useEffect } from "react";
import useSWR from "swr";
import { apiQuran } from "@/lib/api";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Badge } from "@/components/ui/badge";
import { 
  Play, 
  Pause, 
  Image as ImageIcon, 
  FileText, 
  CheckCircle2, 
  AlertCircle,
  Database,
  Music
} from "lucide-react";

export default function QuranTestPanel() {
  const backendBaseUrl = (process.env.NEXT_PUBLIC_API_URL || "http://localhost:5264/api").replace(/\/api$/, "");
  
  const [selectedSurah, setSelectedSurah] = useState<string>("");
  const [selectedAyah, setSelectedAyah] = useState<string>("");
  const [reciter, setReciter] = useState<string>("AbdulSamad"); // Default reciter
  const [mealLanguage, setMealLanguage] = useState<string>("tr"); // Default meal language
  const [integrityResult, setIntegrityResult] = useState<any>(null);
  const [externalTranslation, setExternalTranslation] = useState<any>(null);
  const [audioUrl, setAudioUrl] = useState<string | null>(null);
  const [mealAudioUrl, setMealAudioUrl] = useState<string | null>(null);
  const [images, setImages] = useState<string[]>([]);
  const [surahImages, setSurahImages] = useState<Record<number, string[]>>({});
  
  // Playlist state
  const [playlist, setPlaylist] = useState<string[]>([]);
  const [playlistAyahNumbers, setPlaylistAyahNumbers] = useState<number[]>([]);
  const [currentPlaylistIndex, setCurrentPlaylistIndex] = useState<number>(-1);
  const [isPlaylistPlaying, setIsPlaylistPlaying] = useState<boolean>(false);
  const [activeTab, setActiveTab] = useState<string>("preview");

  // Fetch surahs
  const { data: surahsResponse } = useSWR("/quran/surahs", () => apiQuran.getSurahs());
  const surahs = surahsResponse?.data || [];

  // Fetch reciters
  const { data: recitersResponse } = useSWR("/quran/reciters", () => apiQuran.getReciters());
  const reciters = recitersResponse?.data || [];

  // Fetch ayahs when surah changes
  const { data: ayahsResponse } = useSWR(
    selectedSurah ? `/quran/surahs/${selectedSurah}/ayahs` : null,
    () => apiQuran.getAyahs(parseInt(selectedSurah))
  );
  const ayahs = ayahsResponse?.data || [];

  // Metadata for JSON panel
  const currentAyahMetadata = ayahs.find((a: any) => a.ayahNumber.toString() === selectedAyah);

  // Reset ayah when switching to translation tab
  useEffect(() => {
    if (activeTab === "translation") {
      setSelectedAyah("");
    }
  }, [activeTab]);

  // Sync images with playlist/selection
  useEffect(() => {
    if (isPlaylistPlaying && currentPlaylistIndex >= 0) {
      const currentAyahNum = playlistAyahNumbers[currentPlaylistIndex];
      setImages(surahImages[currentAyahNum] || []);
      // Sync the selection dropdown too if desired, though usually playlist is automatic
    }
  }, [currentPlaylistIndex, isPlaylistPlaying, surahImages, playlistAyahNumbers]);

  // External API call for translation & Media
  useEffect(() => {
    if (selectedSurah && selectedAyah && !isPlaylistPlaying) {
      // Translation text
      fetch(`https://api.acikkuran.com/surah/${selectedSurah}/verse/${selectedAyah}`)
        .then(res => res.json())
        .then(data => setExternalTranslation(data.data))
        .catch(err => console.error("External API error:", err));
      
      // Images (Single selection mode)
      apiQuran.getAyahImages(parseInt(selectedSurah), parseInt(selectedAyah)).then(res => {
        setImages(res.data);
      });

      // Single Ayah Audio
      apiQuran.getAyahAudio(reciter, parseInt(selectedSurah), parseInt(selectedAyah)).then(res => {
          const fullAudioUrl = `${backendBaseUrl}${res.data.audioPath}`;
          setAudioUrl(fullAudioUrl);
      });
    }

    if (selectedSurah) {
      // Meal Audio
      apiQuran.getMealAudio(mealLanguage, parseInt(selectedSurah)).then(res => {
        setMealAudioUrl(res.data.url);
      }).catch(() => setMealAudioUrl(null));
    } else {
      setMealAudioUrl(null);
    }
  }, [selectedSurah, selectedAyah, reciter, mealLanguage]);

  const handleIntegrityCheck = async () => {
    if (!selectedSurah) return;
    const res = await apiQuran.checkIntegrity(parseInt(selectedSurah));
    setIntegrityResult(res.data);
  };

  const handlePlayFullSurah = async () => {
    if (!selectedSurah || !reciter) return;
    
    const [audioRes, imagesRes] = await Promise.all([
      apiQuran.getFullSurahAudio(reciter, parseInt(selectedSurah)),
      apiQuran.getSurahImages(parseInt(selectedSurah))
    ]);
    
    const urls = audioRes.data.map(path => `${backendBaseUrl}${path}`);
    const ayahNums = ayahs.map((a: any) => a.ayahNumber);
    
    setSurahImages(imagesRes.data);
    setPlaylist(urls);
    setPlaylistAyahNumbers(ayahNums);
    setCurrentPlaylistIndex(0);
    setIsPlaylistPlaying(true);
  };

  const handleAyahEnded = () => {
    if (isPlaylistPlaying && currentPlaylistIndex < playlist.length - 1) {
      setCurrentPlaylistIndex(prev => prev + 1);
    } else {
      setIsPlaylistPlaying(false);
      setCurrentPlaylistIndex(-1);
    }
  };

  return (
    <div className="p-6 space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Kur'an Test Paneli</h1>
          <p className="text-muted-foreground">Kur'an veri setini (ses, görsel, metadata) doğrulamak için araçlar.</p>
        </div>
        <Badge variant="outline" className="px-3 py-1 text-sm bg-blue-50 text-blue-700 border-blue-200 dark:bg-blue-900/20 dark:text-blue-400">
          Read-Only Mode
        </Badge>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        {/* Selection Panel */}
        <Card className="md:col-span-1 shadow-sm border-slate-200">
          <CardHeader>
            <CardTitle className="text-lg">Filtreler</CardTitle>
            <CardDescription>Sure ve Ayet seçin</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <label className="text-sm font-medium">Okuyucu (Reciter)</label>
              <Select value={reciter} onValueChange={setReciter}>
                <SelectTrigger>
                  <SelectValue placeholder="Okuyucu Seçin" />
                </SelectTrigger>
                <SelectContent>
                  {reciters.map((r: any) => (
                    <SelectItem key={r.id} value={r.id}>
                      {r.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium">Sure</label>
              <Select value={selectedSurah} onValueChange={setSelectedSurah}>
                <SelectTrigger>
                  <SelectValue placeholder="Sure Seçin" />
                </SelectTrigger>
                <SelectContent>
                  {surahs.map((s: any) => (
                    <SelectItem key={s.id} value={s.id.toString()}>
                      {s.id}. {s.name} ({s.turkishName})
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium">Ayet</label>
              <Select value={selectedAyah} onValueChange={setSelectedAyah} disabled={!selectedSurah}>
                <SelectTrigger>
                  <SelectValue placeholder="Ayet Seçin" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="0">Ayet Seçilmedi (Sure Bazlı)</SelectItem>
                  {ayahs.map((a: any) => (
                    <SelectItem key={a.ayahNumber} value={a.ayahNumber.toString()}>
                      Ayet {a.ayahNumber}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="pt-4 space-y-2 border-t border-slate-100">
              <Button 
                onClick={handlePlayFullSurah} 
                disabled={!selectedSurah || !reciter}
                variant="outline"
                className="w-full border-primary/20 text-primary hover:bg-primary/5"
              >
                <Play className="mr-2 h-4 w-4" />
                Tüm Sureyi Oynat
              </Button>

              <Button 
                onClick={handleIntegrityCheck} 
                disabled={!selectedSurah}
                className="w-full bg-slate-800 hover:bg-slate-700"
              >
                <CheckCircle2 className="mr-2 h-4 w-4" />
                Eksik Dosya Kontrolü
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* content Panel */}
        <div className="md:col-span-3 space-y-6">
          <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
            <TabsList className="grid w-full grid-cols-4 bg-slate-100 dark:bg-slate-800 p-1">
              <TabsTrigger value="preview">Önizleme</TabsTrigger>
              <TabsTrigger value="translation">Meal (Dış API)</TabsTrigger>
              <TabsTrigger value="metadata">Metadata Debug</TabsTrigger>
              <TabsTrigger value="integrity">Doğrulama Raporu</TabsTrigger>
            </TabsList>

            <TabsContent value="preview" className="mt-6 space-y-6">
              {/* Image Preview Card */}
              <Card>
                <CardHeader>
                  <CardTitle className="text-md flex items-center">
                    <ImageIcon className="mr-2 h-5 w-5 text-primary" /> Ayet Görsel Parçaları
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  {!selectedAyah && !isPlaylistPlaying ? (
                     <p className="text-sm text-muted-foreground text-center py-4 italic">Lütfen bir ayet seçin</p>
                  ) : (
                    <div className="grid grid-cols-1 gap-4">
                      {images.map((img, idx) => (
                        <div key={idx} className="bg-white p-4 border rounded-lg shadow-sm">
                           {img && (
                             <img 
                              src={`${backendBaseUrl}${img}`} 
                              alt={`Ayah Partial ${idx}`} 
                              className="max-w-full h-auto mx-auto"
                             />
                           )}
                           <p className="mt-2 text-center text-xs text-slate-500 font-mono">
                             {img}
                           </p>
                        </div>
                      ))}
                    </div>
                  )}
                </CardContent>
              </Card>

              {/* Audio Player Card */}
              <Card>
                <CardHeader>
                  <CardTitle className="text-md flex items-center">
                    <Music className="mr-2 h-5 w-5 text-primary" /> Ayet Ses Dosyası
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  {!selectedAyah && !isPlaylistPlaying ? (
                    <p className="text-sm text-muted-foreground text-center py-4 italic">Lütfen bir ayet seçin veya "Tüm Sureyi Oynat" butonuna basın</p>
                  ) : (
                    <div className="bg-slate-50 dark:bg-slate-900 p-4 rounded-xl border border-slate-200">
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-xs font-semibold text-primary">
                          {isPlaylistPlaying ? `Playlist: Ayet ${playlistAyahNumbers[currentPlaylistIndex]} (${currentPlaylistIndex + 1} / ${playlist.length})` : `Tek Ayet: ${selectedAyah}`}
                        </span>
                        {isPlaylistPlaying && (
                          <Badge variant="secondary" className="bg-primary/10 text-primary border-none">Oynatılıyor...</Badge>
                        )}
                      </div>
                      {(isPlaylistPlaying ? playlist[currentPlaylistIndex] : audioUrl) && (
                        <audio 
                          controls 
                          autoPlay={isPlaylistPlaying}
                          className="w-full" 
                          src={(isPlaylistPlaying ? playlist[currentPlaylistIndex] : audioUrl) || undefined}
                          onEnded={handleAyahEnded}
                        >
                          Your browser does not support the audio element.
                        </audio>
                      )}
                      <p className="mt-2 text-xs text-slate-500 font-mono break-all">
                        {typeof (isPlaylistPlaying ? playlist[currentPlaylistIndex] : audioUrl) === 'string' 
                          ? (isPlaylistPlaying ? playlist[currentPlaylistIndex] : audioUrl) 
                          : 'No URL'}
                      </p>
                    </div>
                  )}
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="translation" className="mt-6 space-y-6">
              {/* Meal Audio Player */}
              <Card>
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <div className="space-y-1">
                    <CardTitle className="text-md flex items-center">
                      <Music className="mr-2 h-5 w-5 text-primary" /> Sure Bazlı Meal Seslendirmesi
                    </CardTitle>
                    <CardDescription>Açık Kur'an Mp3 Arşivi</CardDescription>
                  </div>
                  <div className="flex bg-slate-100 dark:bg-slate-800 p-1 rounded-md">
                    <button 
                      onClick={() => setMealLanguage("tr")}
                      className={`px-3 py-1 text-xs font-semibold rounded ${mealLanguage === "tr" ? 'bg-white shadow-sm' : 'text-muted-foreground'}`}
                    >
                      TR
                    </button>
                    <button 
                      onClick={() => setMealLanguage("en")}
                      className={`px-3 py-1 text-xs font-semibold rounded ${mealLanguage === "en" ? 'bg-white shadow-sm' : 'text-muted-foreground'}`}
                    >
                      EN
                    </button>
                  </div>
                </CardHeader>
                <CardContent>
                  {!selectedSurah ? (
                    <p className="text-sm text-muted-foreground text-center py-2 italic">Lütfen bir sure seçin</p>
                  ) : (
                    <div className="bg-slate-50 dark:bg-slate-900 p-4 rounded-xl border border-slate-200">
                      {mealAudioUrl ? (
                        <audio controls className="w-full" src={mealAudioUrl}>
                          Your browser does not support the audio element.
                        </audio>
                      ) : (
                        <p className="text-xs text-muted-foreground italic text-center">Bu sure için meal dosyası yüklenemedi veya desteklenmiyor.</p>
                      )}
                      <p className="mt-2 text-[10px] text-slate-500 font-mono break-all">
                        {typeof mealAudioUrl === 'string' ? mealAudioUrl : 'No URL'}
                      </p>
                    </div>
                  )}
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="text-md flex items-center">
                    <FileText className="mr-2 h-5 w-5 text-primary" /> Açık Kur'an Metin Verileri
                  </CardTitle>
                  <CardDescription>Canlı API Verileri</CardDescription>
                </CardHeader>
                <CardContent className="space-y-6">
                  {!externalTranslation ? (
                    <p className="text-sm text-muted-foreground text-center py-4 italic">Lütfen bir ayet seçin</p>
                  ) : (
                    <div className="space-y-4">
                      <div className="bg-emerald-50 dark:bg-emerald-950/20 p-6 rounded-xl border-l-4 border-emerald-500">
                        <h4 className="text-sm font-bold text-emerald-800 dark:text-emerald-300 uppercase mb-2">Arapça Metin</h4>
                        <p className="text-2xl leading-relaxed text-right font-serif" dir="rtl">{externalTranslation.verse}</p>
                      </div>

                      <div className="bg-slate-50 dark:bg-slate-900 p-6 rounded-xl border border-slate-200">
                         <h4 className="text-sm font-bold text-slate-700 dark:text-slate-300 uppercase mb-2">Meal ({externalTranslation.translation.author})</h4>
                         <p className="text-lg leading-relaxed">{externalTranslation.translation.text}</p>
                      </div>

                      <div className="bg-blue-50 dark:bg-blue-950/20 p-6 rounded-xl border border-blue-200">
                         <h4 className="text-sm font-bold text-blue-700 dark:text-blue-300 uppercase mb-2">Transkripsiyon</h4>
                         <p className="text-md leading-relaxed italic">
                           {typeof externalTranslation.transcription === 'string' ? externalTranslation.transcription : ''}
                         </p>
                      </div>
                    </div>
                  )}
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="metadata" className="mt-6">
              <Card>
                <CardHeader>
                  <CardTitle className="text-md flex items-center">
                    <Database className="mr-2 h-5 w-5 text-primary" /> Metadata JSON View
                  </CardTitle>
                </CardHeader>
                <CardContent>
                   {!currentAyahMetadata ? (
                     <p className="text-sm text-muted-foreground text-center py-4 italic">Lütfen bir ayet seçin</p>
                   ) : (
                    <pre className="bg-slate-900 text-slate-100 p-6 rounded-xl overflow-x-auto text-xs font-mono">
                      {JSON.stringify({
                        ...currentAyahMetadata,
                        audioUrl,
                        images: images.map(img => `${backendBaseUrl}${img}`),
                        externalTranslation
                      }, null, 2)}
                    </pre>
                   )}
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="integrity" className="mt-6">
              <Card>
                <CardHeader>
                  <CardTitle className="text-md flex items-center">
                    <CheckCircle2 className="mr-2 h-5 w-5 text-primary" /> Eksik Dosya Raporu
                  </CardTitle>
                  <CardDescription>Sure bazında dosya tamlık analizi</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  {!integrityResult ? (
                    <div className="text-center py-10">
                      <AlertCircle className="mx-auto h-12 w-12 text-slate-300 mb-4" />
                      <p className="text-muted-foreground">Kontrol başlatmak için "Eksik Dosya Kontrolü" butonuna basın.</p>
                    </div>
                  ) : (
                    <div className="space-y-6">
                      <div className="grid grid-cols-2 gap-4">
                        <div className={`p-4 rounded-lg border ${integrityResult.missingAudioAyahs.length > 0 ? 'bg-orange-50 border-orange-200' : 'bg-green-50 border-green-200'}`}>
                           <p className="text-sm font-medium">Eksik Ses Sayısı</p>
                           <p className="text-2xl font-bold">{integrityResult.missingAudioAyahs.length}</p>
                        </div>
                        <div className={`p-4 rounded-lg border ${integrityResult.missingImageAyahs.length > 0 ? 'bg-orange-50 border-orange-200' : 'bg-green-50 border-green-200'}`}>
                           <p className="text-sm font-medium">Eksik Görsel Sayısı</p>
                           <p className="text-2xl font-bold">{integrityResult.missingImageAyahs.length}</p>
                        </div>
                      </div>

                      {integrityResult.missingAudioAyahs.length > 0 && (
                        <div className="space-y-2">
                          <Alert variant="warning" className="bg-amber-50 border-amber-200 text-amber-800">
                            <AlertCircle className="h-4 w-4" />
                            <AlertTitle>Eksik Ses Dosyaları</AlertTitle>
                            <AlertDescription>
                              Aşağıdaki ayetler için ses dosyası bulunamadı.
                            </AlertDescription>
                          </Alert>
                          <div className="flex flex-wrap gap-2">
                             {integrityResult.missingAudioAyahs.map((id: string) => (
                               <Badge key={id} variant="secondary" className="bg-amber-100 text-amber-700 hover:bg-amber-100 border-amber-200">
                                 {id}
                               </Badge>
                             ))}
                          </div>
                        </div>
                      )}

                      {integrityResult.missingImageAyahs.length > 0 && (
                        <div className="space-y-2">
                          <Alert variant="warning" className="bg-amber-50 border-amber-200 text-amber-800">
                            <AlertCircle className="h-4 w-4" />
                            <AlertTitle>Eksik Görsel Parçaları</AlertTitle>
                            <AlertDescription>
                              Aşağıdaki ayetler için görsel parçaları eksik veya bozuk.
                            </AlertDescription>
                          </Alert>
                          <div className="flex flex-wrap gap-2">
                             {integrityResult.missingImageAyahs.map((id: string) => (
                               <Badge key={id} variant="secondary" className="bg-amber-100 text-amber-700 hover:bg-amber-100 border-amber-200">
                                 {id}
                               </Badge>
                             ))}
                          </div>
                        </div>
                      )}

                      {integrityResult.isComplete && (
                        <Alert className="bg-green-50 border-green-200 text-green-800">
                          <CheckCircle2 className="h-4 w-4 text-green-600" />
                          <AlertTitle>Tüm Dosyalar Tam!</AlertTitle>
                          <AlertDescription>
                            Bu sure için tüm ses ve görsel dosyaları başarıyla doğrulandı.
                          </AlertDescription>
                        </Alert>
                      )}
                    </div>
                  )}
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>
        </div>
      </div>
    </div>
  );
}
