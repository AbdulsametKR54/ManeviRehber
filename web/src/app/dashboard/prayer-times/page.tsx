"use client";

import { useEffect, useState } from "react";
import axios from "@/lib/axios";
import { format } from "date-fns";
import { tr } from "date-fns/locale";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";

export default function PrayerTimesPage() {
    const [countries, setCountries] = useState<any[]>([]);
    const [cities, setCities] = useState<any[]>([]);
    const [districts, setDistricts] = useState<any[]>([]);

    const [countryId, setCountryId] = useState("");
    const [cityId, setCityId] = useState("");
    const [districtId, setDistrictId] = useState("");
    const [date, setDate] = useState("");

    const [result, setResult] = useState<any>(null);
    const [testing, setTesting] = useState(false);

    // Ülkeleri yükle
    useEffect(() => {
        axios.get("/Location/countries").then((res) => {
            setCountries(res.data);
        }).catch(err => console.error(err));
    }, []);

    // Ülke seçilince illeri getir
    useEffect(() => {
        if (!countryId) return;
        axios.get(`/Location/cities/${countryId}`).then((res) => {
            setCities(res.data);
            setDistricts([]);
            setCityId("");
            setDistrictId("");
        }).catch(err => console.error(err));
    }, [countryId]);

    // İl seçilince ilçeleri getir
    useEffect(() => {
        if (!cityId) return;
        axios.get(`/Location/districts/${cityId}`).then((res) => {
            setDistricts(res.data);
            setDistrictId("");
        }).catch(err => console.error(err));
    }, [cityId]);

    const handleTest = async () => {
        if (!districtId || !date) {
            alert("Lütfen ilçe ve tarih seçiniz.");
            return;
        }

        const dateObj = new Date(date);
        const year = dateObj.getFullYear();
        const month = dateObj.getMonth() + 1; // getMonth() returns 0-11

        setTesting(true);
        try {
            const res = await axios.get(`/PrayerTime/monthly/${districtId}/${year}/${month}`);
            const data: any[] = res.data;

            // Seçilen tarihi en başa al, diğerlerini arkasına ekle
            const selectedDateString = format(dateObj, 'yyyy-MM-dd');
            const selectedItem = data.find(item => item.date.startsWith(selectedDateString));
            const otherItems = data.filter(item => !item.date.startsWith(selectedDateString));

            const orderedResult = selectedItem ? [selectedItem, ...otherItems] : data;

            setResult(orderedResult);
        } catch (error) {
            console.error("Test hatası", error);
            alert("Namaz vakitleri alınamadı. Lütfen backend bağlantısını kontrol edin.");
        } finally {
            setTesting(false);
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">Namaz Vakitleri</h1>
                    <p className="text-muted-foreground mt-1">Lokasyon hiyerarşisine göre (Ülke -{">"} İl -{">"} İlçe) namaz vakitlerini test edin.</p>
                </div>
            </div>

            <div className="rounded-lg border border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900 shadow-sm p-6 mt-6">
                <h2 className="text-xl font-semibold mb-2">Vakit Testi Seçenekleri</h2>
                <p className="text-sm text-muted-foreground mb-6">Test etmek istediğiniz lokasyon ve tarihi seçin.</p>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 items-end mb-6">
                    <div className="space-y-2">
                        <label className="text-sm font-semibold text-muted-foreground ml-1">Ülke</label>
                        <Select value={countryId} onValueChange={setCountryId}>
                            <SelectTrigger className="h-11 rounded-xl bg-slate-50 dark:bg-slate-900/50 focus:ring-primary/20 transition-all">
                                <SelectValue placeholder="Ülke Seç" />
                            </SelectTrigger>
                            <SelectContent>
                                {countries.map((c) => (
                                    <SelectItem key={c.ulkeID} value={c.ulkeID.toString()}>{c.ulkeAdi}</SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                    </div>

                    <div className="space-y-2">
                        <label className="text-sm font-semibold text-muted-foreground ml-1">İl</label>
                        <Select value={cityId} onValueChange={setCityId} disabled={!countryId}>
                            <SelectTrigger className="h-11 rounded-xl bg-slate-50 dark:bg-slate-900/50 focus:ring-primary/20 transition-all">
                                <SelectValue placeholder="İl Seç" />
                            </SelectTrigger>
                            <SelectContent>
                                {cities.map((c) => (
                                    <SelectItem key={c.sehirID} value={c.sehirID.toString()}>{c.sehirAdi}</SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                    </div>

                    <div className="space-y-2">
                        <label className="text-sm font-semibold text-muted-foreground ml-1">İlçe</label>
                        <Select value={districtId} onValueChange={setDistrictId} disabled={!cityId}>
                            <SelectTrigger className="h-11 rounded-xl bg-slate-50 dark:bg-slate-900/50 focus:ring-primary/20 transition-all">
                                <SelectValue placeholder="İlçe Seç" />
                            </SelectTrigger>
                            <SelectContent>
                                {districts.map((d) => (
                                    <SelectItem key={d.ilceID} value={d.ilceID.toString()}>{d.ilceAdi}</SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                    </div>

                    <div className="space-y-2">
                        <label className="text-sm font-semibold text-muted-foreground ml-1">Tarih</label>
                        <Input
                            type="date"
                            className="h-11 rounded-xl bg-slate-50 dark:bg-slate-900/50 focus:ring-primary/20 transition-all px-4"
                            value={date}
                            onChange={(e) => setDate(e.target.value)}
                        />
                    </div>
                </div>

                <Button
                    onClick={handleTest}
                    disabled={testing || !districtId || !date}
                    className="w-full lg:w-auto h-11 px-8 rounded-xl font-semibold bg-primary hover:bg-primary/90 text-white shadow-lg shadow-primary/20 transition-all focus:ring-4 focus:ring-primary/20"
                >
                    {testing ? "Test Ediliyor..." : "Test Et"}
                </Button>
            </div>

            {result && result.length > 0 && (
                <div className="rounded-lg border border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900 shadow-sm p-6 mt-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
                    <h2 className="text-xl font-semibold mb-2">Test Sonucu (Aylık)</h2>
                    <p className="text-sm text-muted-foreground mb-6">Seçilen tarih en üstte listelenmektedir.</p>
                    <div className="mt-4">
                        <div className="overflow-x-auto max-h-[500px]">
                            <table className="w-full border-separate border-spacing-0 text-sm">
                                <thead>
                                    <tr className="sticky top-0 z-10">
                                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Tarih</th>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">İmsak</th>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700 text-amber-500">Güneş</th>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700 text-emerald-500">Öğle</th>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700 text-blue-500">İkindi</th>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700 text-orange-500">Akşam</th>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700 text-indigo-500">Yatsı</th>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-right px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Hicri Tarih</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {result.map((item: any, index: number) => (
                                        <tr
                                            key={index}
                                            className={`
                                                ${index === 0 ? "bg-primary/10 hover:bg-primary/15" : (index % 2 === 1 ? "bg-white dark:bg-gray-900" : "bg-gray-50 dark:bg-gray-800")}
                                                hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors
                                            `}
                                        >
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 whitespace-nowrap font-medium">
                                                {item.date ? format(new Date(item.date), 'dd MMM yyyy', { locale: tr }) : item.date}
                                            </td>
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 font-mono">{item.fajr}</td>
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 font-mono font-medium text-amber-600 dark:text-amber-400">{item.sunrise}</td>
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 font-mono font-medium text-emerald-600 dark:text-emerald-400">{item.dhuhr}</td>
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 font-mono font-medium text-blue-600 dark:text-blue-400">{item.asr}</td>
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 font-mono font-medium text-orange-600 dark:text-orange-400">{item.maghrib}</td>
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 font-mono font-medium text-indigo-600 dark:text-indigo-400">{item.isha}</td>
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 text-right text-muted-foreground text-sm">{item.hijriDateLong}</td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
