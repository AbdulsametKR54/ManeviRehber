"use client";

import React, { useState, useEffect } from "react";
import useSWR from "swr";
import { apiQuran } from "@/lib/api";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
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
  Music,
  Search,
  BookOpen
} from "lucide-react";

export default function QuranTestPanel() {
  const backendBaseUrl = (process.env.NEXT_PUBLIC_API_URL || "http://localhost:5264/api").replace(/\/api$/, "");
  
  const [selectedSurah, setSelectedSurah] = useState<string>("");
  const [selectedAyah, setSelectedAyah] = useState<string>("");
  const [reciter, setReciter] = useState<string>("AbdulSamad");
  const [mealLanguage, setMealLanguage] = useState<string>("tr");
  const [integrityResult, setIntegrityResult] = useState<any>(null);
  
  // Media States
  const [audioUrl, setAudioUrl] = useState<string | null>(null);
  const [mealAudioUrl, setMealAudioUrl] = useState<string | null>(null);
  const [images, setImages] = useState<string[]>([]);
  const [surahImages, setSurahImages] = useState<Record<number, string[]>>({});
  
  // OpenAPI States
  const [openSurahDetails, setOpenSurahDetails] = useState<any>(null);
  const [openVerseDetail, setOpenVerseDetail] = useState<any>(null);
  const [openVerseTranslations, setOpenVerseTranslations] = useState<any>(null);
  const [openVerseParts, setOpenVerseParts] = useState<any>(null);

  const [latinRoot, setLatinRoot] = useState<string>("");
  const [openRootDetails, setOpenRootDetails] = useState<any>(null);
  const [openRootVerseParts, setOpenRootVerseParts] = useState<any>(null);

  const [pageNumber, setPageNumber] = useState<string>("1");
  const [openPageVerses, setOpenPageVerses] = useState<any>(null);

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

  // Sync images with playlist/selection
  useEffect(() => {
    if (isPlaylistPlaying && currentPlaylistIndex >= 0) {
      const currentAyahNum = playlistAyahNumbers[currentPlaylistIndex];
      setImages(surahImages[currentAyahNum] || []);
    }
  }, [currentPlaylistIndex, isPlaylistPlaying, surahImages, playlistAyahNumbers]);

  // Handle data fetching for core media and api proxy
  useEffect(() => {
    // 1. Ayet state'lerini sıfırla (Eski veri kalmasın ve çökmeyi engellesin)
    setOpenVerseDetail(null);
    setOpenVerseTranslations(null);
    setOpenVerseParts(null);
    setAudioUrl(null);
    setImages([]);

    // 2. Eğer "Ayet Seçilmedi" ("0") değilse çalışır
    if (selectedSurah && selectedAyah && selectedAyah !== "0" && !isPlaylistPlaying) {
      // Images (Single selection mode)
      apiQuran.getAyahImages(parseInt(selectedSurah), parseInt(selectedAyah))
        .then(res => setImages(res.data || []))
        .catch(() => setImages([]));

      // Single Ayah Audio
      apiQuran.getAyahAudio(reciter, parseInt(selectedSurah), parseInt(selectedAyah))
        .then(res => {
          if (res.data?.audioPath) {
             const fullAudioUrl = `${backendBaseUrl}${res.data.audioPath}`;
             setAudioUrl(fullAudioUrl);
          }
      }).catch(() => setAudioUrl(null));

      // API 2: Ayet Detayı
      apiQuran.getOpenVerseDetail(parseInt(selectedSurah), parseInt(selectedAyah))
        .then(res => setOpenVerseDetail(res.data?.data || res.data))
        .catch(err => console.error(err));

      // API 3: Ayet Mealleri
      apiQuran.getOpenVerseTranslations(parseInt(selectedSurah), parseInt(selectedAyah))
        .then(res => setOpenVerseTranslations(res.data?.data || res.data))
        .catch(err => console.error(err));

      // API 6: Ayet VerseParts
      apiQuran.getOpenVerseParts(parseInt(selectedSurah), parseInt(selectedAyah))
        .then(res => setOpenVerseParts(res.data?.data || res.data))
        .catch(err => console.error(err));
    }

    if (selectedSurah) {
      // Meal Audio
      apiQuran.getMealAudio(mealLanguage, parseInt(selectedSurah)).then(res => {
         if (res.data?.url) setMealAudioUrl(res.data.url);
      }).catch(() => setMealAudioUrl(null));

      // API 1: Sure Detayları
      apiQuran.getOpenSurahDetails(parseInt(selectedSurah))
        .then(res => setOpenSurahDetails(res.data?.data || res.data))
        .catch(err => console.error(err));
    } else {
      setMealAudioUrl(null);
      setOpenSurahDetails(null);
    }
  }, [selectedSurah, selectedAyah, reciter, mealLanguage, isPlaylistPlaying]);

  const handleRootSearch = () => {
    if (!latinRoot) return;
    setOpenRootDetails(null);
    setOpenRootVerseParts(null);
    
    // API 4: Kök Detayı
    apiQuran.getOpenRootDetails(latinRoot)
       .then(res => setOpenRootDetails(res.data?.data || res.data))
       .catch(err => console.error(err));
       
    // API 5: Kökten Geçen Kelimeler (Verseparts)
    apiQuran.getOpenRootVerseParts(latinRoot)
       .then(res => setOpenRootVerseParts(res.data?.data || res.data))
       .catch(err => console.error(err));
  };

  const handlePageSearch = () => {
    if (!pageNumber) return;
    setOpenPageVerses(null);
    
    // API 7: Sayfa (Mushaf)
    apiQuran.getOpenPageVerses(parseInt(pageNumber))
       .then(res => setOpenPageVerses(res.data?.data || res.data))
       .catch(err => console.error(err));
  };

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
          <p className="text-muted-foreground">Kur'an API proxy ve lokal dataset doğrulama araçları.</p>
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
                  <SelectItem value="0">Ayet Seçilmedi</SelectItem>
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

        {/* Content Panel */}
        <div className="md:col-span-3 space-y-6">
          <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
            <TabsList className="flex flex-wrap h-auto bg-slate-100 dark:bg-slate-800 p-1 rounded-lg">
              <TabsTrigger value="preview" className="flex-1 text-xs sm:text-sm">Medya</TabsTrigger>
              <TabsTrigger value="openapi-surah" className="flex-1 text-xs sm:text-sm">Sûre/Ayet</TabsTrigger>
              <TabsTrigger value="openapi-root" className="flex-1 text-xs sm:text-sm">Kök</TabsTrigger>
              <TabsTrigger value="openapi-page" className="flex-1 text-xs sm:text-sm">Sayfa</TabsTrigger>
              <TabsTrigger value="metadata" className="flex-1 text-xs sm:text-sm">Metadata</TabsTrigger>
              <TabsTrigger value="integrity" className="flex-1 text-xs sm:text-sm">Rapor</TabsTrigger>
            </TabsList>

            <TabsContent value="preview" className="mt-6 space-y-6">
              <Card>
                <CardHeader>
                  <CardTitle className="text-md flex items-center">
                    <ImageIcon className="mr-2 h-5 w-5 text-primary" /> Ayet Görsel Parçaları
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  {(!selectedAyah || selectedAyah === "0") && !isPlaylistPlaying ? (
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

              <Card>
                <CardHeader>
                  <CardTitle className="text-md flex items-center">
                    <Music className="mr-2 h-5 w-5 text-primary" /> Ayet Ses Dosyası
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  {(!selectedAyah || selectedAyah === "0") && !isPlaylistPlaying ? (
                    <p className="text-sm text-muted-foreground text-center py-4 italic">Lütfen bir ayet seçin</p>
                  ) : (
                    <div className="bg-slate-50 dark:bg-slate-900 p-4 rounded-xl border border-slate-200">
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-xs font-semibold text-primary">
                          {isPlaylistPlaying ? `Playlist: Ayet ${playlistAyahNumbers[currentPlaylistIndex]}` : `Tek Ayet: ${selectedAyah}`}
                        </span>
                        {isPlaylistPlaying && <Badge variant="secondary" className="bg-primary/10 text-primary border-none">Oynatılıyor...</Badge>}
                      </div>
                      {(isPlaylistPlaying ? playlist[currentPlaylistIndex] : audioUrl) && (
                        <audio 
                          controls 
                          autoPlay={isPlaylistPlaying}
                          className="w-full" 
                          src={(isPlaylistPlaying ? playlist[currentPlaylistIndex] : audioUrl) || undefined}
                          onEnded={handleAyahEnded}
                        />
                      )}
                    </div>
                  )}
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <div className="space-y-1">
                     <CardTitle className="text-md flex items-center">
                       <Music className="mr-2 h-5 w-5 text-primary" /> Meal Seslendirmesi
                     </CardTitle>
                  </div>
                  <div className="flex bg-slate-100 dark:bg-slate-800 p-1 rounded-md">
                    <button onClick={() => setMealLanguage("tr")} className={`px-3 py-1 text-xs font-semibold rounded ${mealLanguage === "tr" ? 'bg-white shadow-sm' : 'text-muted-foreground'}`}>TR</button>
                    <button onClick={() => setMealLanguage("en")} className={`px-3 py-1 text-xs font-semibold rounded ${mealLanguage === "en" ? 'bg-white shadow-sm' : 'text-muted-foreground'}`}>EN</button>
                  </div>
                </CardHeader>
                <CardContent>
                  {!selectedSurah ? (
                    <p className="text-sm text-muted-foreground text-center py-2 italic">Lütfen bir sure seçin</p>
                  ) : (
                    <div className="bg-slate-50 dark:bg-slate-900 p-4 rounded-xl border border-slate-200">
                      {mealAudioUrl ? (
                         <audio controls className="w-full" src={mealAudioUrl} />
                      ) : (
                         <p className="text-xs text-muted-foreground italic text-center">Dosya desteklenmiyor.</p>
                      )}
                    </div>
                  )}
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="openapi-surah" className="mt-6 space-y-6">
              {/* API 1 */}
              <Card>
                <CardHeader>
                  <CardTitle className="text-sm font-bold text-slate-500 uppercase">1. Sûre Detayı</CardTitle>
                </CardHeader>
                <CardContent>
                  {!openSurahDetails || typeof openSurahDetails !== 'object' ? <p className="text-sm italic text-muted-foreground">Sure seçimi bekleniyor veya veri yok</p> : (
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm bg-slate-50 p-4 rounded-xl">
                      <div><span className="text-slate-500 block text-xs">Adı</span><strong className="font-serif">{openSurahDetails.name} ({openSurahDetails.name_original})</strong></div>
                      <div><span className="text-slate-500 block text-xs">Ayet Sayısı</span><strong>{openSurahDetails.verse_count}</strong></div>
                      <div><span className="text-slate-500 block text-xs">Açıklama</span><strong className="capitalize">{openSurahDetails.name_translation_tr}</strong></div>
                      <div><span className="text-slate-500 block text-xs">Slug</span><strong>{openSurahDetails.slug}</strong></div>
                    </div>
                  )}
                </CardContent>
              </Card>

              {/* API 2 & 6 */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <Card>
                  <CardHeader>
                    <CardTitle className="text-sm font-bold text-slate-500 uppercase">2. Ayet Detayı</CardTitle>
                  </CardHeader>
                  <CardContent>
                    {!openVerseDetail || typeof openVerseDetail !== 'object' ? <p className="text-sm italic text-muted-foreground">Ayet seçimi bekleniyor veya veri yok</p> : (
                      <div className="space-y-4">
                        <div className="p-4 bg-emerald-50 rounded-lg">
                          <h4 className="text-right text-3xl font-serif text-emerald-900" dir="rtl">{openVerseDetail.verse}</h4>
                        </div>
                        <p className="p-4 bg-slate-50 italic text-slate-700 rounded-lg">{openVerseDetail.transcription}</p>
                      </div>
                    )}
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="text-sm font-bold text-slate-500 uppercase">6. Ayet VerseParts</CardTitle>
                  </CardHeader>
                  <CardContent>
                    {!openVerseParts || !Array.isArray(openVerseParts) || openVerseParts.length === 0 ? <p className="text-sm italic text-muted-foreground">Ayet seçimi bekleniyor veya veri bulunamadı</p> : (
                      <div className="flex flex-wrap gap-2 justify-end" dir="rtl">
                        {openVerseParts.map((vp: any, idx: number) => (
                          <div key={idx} className="bg-slate-50 border p-3 rounded-lg text-center shadow-sm">
                            <p className="font-serif text-xl">{vp.arabic || vp.word}</p>
                            <p className="text-[10px] text-emerald-700 font-semibold mb-1">{vp.translation_tr || vp.translation}</p>
                            {vp.root && typeof vp.root === 'object' && <Badge variant="secondary" className="text-[10px] bg-sky-100 text-sky-800 border-none">{vp.root.latin || vp.root.arabic}</Badge>}
                          </div>
                        ))}
                      </div>
                    )}
                  </CardContent>
                </Card>
              </div>

              {/* API 3 */}
              <Card>
                <CardHeader>
                  <CardTitle className="text-sm font-bold text-slate-500 uppercase">3. Ayet Mealleri</CardTitle>
                </CardHeader>
                <CardContent>
                  {!openVerseTranslations || !Array.isArray(openVerseTranslations) ? <p className="text-sm italic text-muted-foreground">Ayet seçimi bekleniyor veya veri yok</p> : (
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 max-h-[400px] overflow-y-auto pr-2">
                       {openVerseTranslations.map((t: any) => (
                          <div key={t.id} className="p-4 border rounded-xl bg-white shadow-sm hover:border-primary/30 transition-colors">
                            <div className="flex items-center gap-2 mb-2">
                               <Badge variant="outline" className="text-[10px] bg-slate-100 text-slate-600 border-none">{t.author?.language || 'TR'}</Badge>
                               <span className="font-semibold text-xs text-slate-800">{t.author?.name || "Bilinmeyen Çevirmen"}</span>
                            </div>
                            <p className="text-sm text-slate-700 leading-relaxed">{t.text}</p>
                          </div>
                       ))}
                    </div>
                  )}
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="openapi-root" className="mt-6 space-y-6">
               <Card>
                  <CardHeader>
                    <CardTitle className="text-sm font-bold text-slate-500 uppercase">4. Kök Doğrulama</CardTitle>
                    <CardDescription>Arapça Kök analizi için Latin (örn: slm, ktb) kullanın.</CardDescription>
                  </CardHeader>
                  <CardContent>
                     <div className="flex gap-2 max-w-sm mb-6">
                       <Input 
                         placeholder="Latin form..." 
                         value={latinRoot} 
                         onChange={(e) => setLatinRoot(e.target.value)}
                         onKeyDown={(e) => e.key === 'Enter' && handleRootSearch()}
                       />
                       <Button onClick={handleRootSearch}><Search className="w-4 h-4 mr-2" /> Ara</Button>
                     </div>

                     {openRootDetails && typeof openRootDetails === 'object' && (
                       <div className="inline-block p-6 bg-emerald-50 border border-emerald-100 rounded-xl text-center">
                         <p className="text-4xl font-serif text-emerald-900 mb-2">{openRootDetails.arabic}</p>
                         <p className="text-sm text-emerald-700 uppercase tracking-widest">{openRootDetails.latin}</p>
                       </div>
                     )}
                  </CardContent>
               </Card>

               {/* API 5 */}
               <Card>
                  <CardHeader>
                    <CardTitle className="text-sm font-bold text-slate-500 uppercase">5. Kökten Geçen Ayet Parçaları</CardTitle>
                  </CardHeader>
                  <CardContent>
                    {!openRootVerseParts || !Array.isArray(openRootVerseParts) ? (
                      <p className="text-sm text-muted-foreground italic">Henüz arama yapılmadı veya sonuç yok.</p>
                    ) : (
                      <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-3">
                        {openRootVerseParts.map((vp: any, idx: number) => (
                          <div key={idx} className="p-3 bg-slate-50 hover:bg-slate-100 border rounded-xl text-center transition-colors">
                            <p className="font-serif text-2xl text-slate-800 mb-1">{vp.arabic || vp.word}</p>
                            <p className="text-[10px] text-primary font-bold">{vp.translation_tr || vp.translation}</p>
                            <Badge variant="outline" className="mt-2 text-[9px] text-slate-400">AYET: {vp.verse?.verse_number || vp.verseId}</Badge>
                          </div>
                        ))}
                      </div>
                    )}
                  </CardContent>
               </Card>
            </TabsContent>

            <TabsContent value="openapi-page" className="mt-6">
              <Card>
                <CardHeader>
                  <CardTitle className="text-sm font-bold text-slate-500 uppercase">7. Sayfa Bazlı Mushaf</CardTitle>
                  <CardDescription>1 ile 604 arasında bir sayfa numarası girin.</CardDescription>
                </CardHeader>
                <CardContent>
                   <div className="flex gap-2 max-w-sm mb-6">
                     <Input 
                       type="number" min="1" max="604" 
                       placeholder="Sayfa No" 
                       value={pageNumber} 
                       onChange={(e) => setPageNumber(e.target.value)}
                       onKeyDown={(e) => e.key === 'Enter' && handlePageSearch()}
                     />
                     <Button onClick={handlePageSearch} variant="secondary"><BookOpen className="w-4 h-4 mr-2" /> Getir</Button>
                   </div>

                   {openPageVerses && Array.isArray(openPageVerses) ? (
                     <div className="p-8 bg-amber-50/50 dark:bg-slate-900 border border-amber-100 rounded-2xl shadow-inner">
                        <div className="text-center mb-6">
                           <Badge variant="outline" className="bg-amber-100 text-amber-800 border-amber-200">Sayfa {pageNumber}</Badge>
                        </div>
                        <div className="flex flex-wrap gap-x-2 gap-y-4 justify-center" dir="rtl">
                           {openPageVerses.map((v: any, idx: number) => (
                             <span key={idx} className="text-2xl lg:text-3xl font-serif text-amber-950 dark:text-amber-100 leading-[2.5] inline-flex items-center">
                               {v.verse}
                               <span className="mx-2 inline-flex items-center justify-center w-8 h-8 rounded-full border-2 border-amber-300 text-[10px] text-amber-700 font-bold bg-white">
                                 {v.verse_number || v.verseNumber}
                               </span>
                             </span>
                           ))}
                        </div>
                     </div>
                   ) : (
                     <p className="text-sm text-muted-foreground italic">Sayfa verisi bekleniyor...</p>
                   )}
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="metadata" className="mt-6">
               <Card>
                 <CardHeader>
                   <CardTitle className="text-md flex items-center">
                     <Database className="mr-2 h-5 w-5 text-primary" /> Debug Metadata
                   </CardTitle>
                 </CardHeader>
                 <CardContent>
                    {!currentAyahMetadata && !openSurahDetails ? (
                      <p className="text-sm text-muted-foreground text-center py-4 italic">Lütfen bir işlem yapın</p>
                    ) : (
                      <pre className="bg-slate-900 text-green-400 p-6 rounded-xl overflow-x-auto text-[10px] font-mono leading-relaxed shadow-inner border border-slate-800">
                        {JSON.stringify({
                          internalMetadata: currentAyahMetadata,
                          openSurahDetails,
                          openVerseDetail,
                          page: pageNumber,
                          root: latinRoot
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
