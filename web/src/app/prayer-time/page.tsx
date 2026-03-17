"use client";

import { useEffect, useState } from "react";
import apiClient from "@/lib/axios";
import { PrayerTimeDto, CountryDto, CityDto, DistrictDto } from "@/types/dto";
import { Button } from "@/components/ui/button";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";

export default function PrayerTimePage() {
    const [countries, setCountries] = useState<CountryDto[]>([]);
    const [cities, setCities] = useState<CityDto[]>([]);
    const [districts, setDistricts] = useState<DistrictDto[]>([]);

    const [selectedCountry, setSelectedCountry] = useState<number | null>(null);
    const [selectedCity, setSelectedCity] = useState<number | null>(null);
    const [selectedDistrict, setSelectedDistrict] = useState<number | null>(null);

    const [date, setDate] = useState<string>("");
    const [times, setTimes] = useState<PrayerTimeDto[]>([]);
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        fetchCountries();
    }, []);

    const fetchCountries = async () => {
        try {
            const { data } = await apiClient.get<CountryDto[]>("/location/countries");
            setCountries(data);
        } catch (e) { console.error(e); }
    };

    const handleCountryChange = async (countryId: number) => {
        setSelectedCountry(countryId);
        setSelectedCity(null);
        setSelectedDistrict(null);
        setCities([]);
        setDistricts([]);
        try {
            const { data } = await apiClient.get<CityDto[]>(`/location/cities/${countryId}`);
            setCities(data);
        } catch (e) { console.error(e); }
    };

    const handleCityChange = async (cityId: number) => {
        setSelectedCity(cityId);
        setSelectedDistrict(null);
        setDistricts([]);
        try {
            const { data } = await apiClient.get<DistrictDto[]>(`/location/districts/${cityId}`);
            setDistricts(data);
        } catch (e) { console.error(e); }
    };

    const handleFetchTimes = async () => {
        if (!selectedDistrict || !date) return;

        setLoading(true);
        try {
            const dateObj = new Date(date);
            const year = dateObj.getFullYear();
            const month = dateObj.getMonth() + 1;

            // GET /api/PrayerTime/monthly/{locationId}/{year}/{month}
            const { data } = await apiClient.get<PrayerTimeDto[]>(
                `/PrayerTime/monthly/${selectedDistrict}/${year}/${month}`
            );
            setTimes(data);
        } catch (error) {
            console.error("Vakitler getirilemedi:", error);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="p-8 space-y-6">
            <h1 className="text-3xl font-bold">Namaz Vakitleri</h1>

            <div className="grid grid-cols-1 md:grid-cols-4 gap-4 bg-white dark:bg-zinc-800 p-6 rounded-lg shadow-sm border dark:border-zinc-700">
                <label className="flex flex-col space-y-2">
                    <span className="text-sm font-medium">Ülke</span>
                    <select
                        className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                        onChange={(e) => handleCountryChange(Number(e.target.value))}
                        value={selectedCountry || ""}
                    >
                        <option value="" disabled>Seçiniz</option>
                        {countries.map(c => <option key={c.ulkeID} value={c.ulkeID}>{c.ulkeAdi}</option>)}
                    </select>
                </label>

                <label className="flex flex-col space-y-2">
                    <span className="text-sm font-medium">Şehir</span>
                    <select
                        className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm disabled:opacity-50"
                        onChange={(e) => handleCityChange(Number(e.target.value))}
                        value={selectedCity || ""}
                        disabled={!selectedCountry}
                    >
                        <option value="" disabled>Seçiniz</option>
                        {cities.map(c => <option key={c.sehirID} value={c.sehirID}>{c.sehirAdi}</option>)}
                    </select>
                </label>

                <label className="flex flex-col space-y-2">
                    <span className="text-sm font-medium">İlçe</span>
                    <select
                        className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm disabled:opacity-50"
                        onChange={(e) => setSelectedDistrict(Number(e.target.value))}
                        value={selectedDistrict || ""}
                        disabled={!selectedCity}
                    >
                        <option value="" disabled>Seçiniz</option>
                        {districts.map(d => <option key={d.ilceID} value={d.ilceID}>{d.ilceAdi}</option>)}
                    </select>
                </label>

                <label className="flex flex-col space-y-2">
                    <span className="text-sm font-medium">Tarih</span>
                    <input
                        type="date"
                        className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                        onChange={(e) => setDate(e.target.value)}
                        value={date}
                    />
                </label>

                <div className="md:col-span-4 flex justify-end">
                    <Button onClick={handleFetchTimes} disabled={!selectedDistrict || !date || loading}>
                        {loading ? "Sorgulanıyor..." : "Vakitleri Getir"}
                    </Button>
                </div>
            </div>

            <div className="border rounded-md bg-white dark:bg-zinc-900 border-zinc-200 dark:border-zinc-800 mt-6">
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>Tarih</TableHead>
                            <TableHead>İmsak</TableHead>
                            <TableHead>Güneş</TableHead>
                            <TableHead>Öğle</TableHead>
                            <TableHead>İkindi</TableHead>
                            <TableHead>Akşam</TableHead>
                            <TableHead>Yatsı</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {times.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={7} className="text-center py-8 text-zinc-500">
                                    Veri yok. Lütfen lokasyon ve tarih seçip sorgulayın.
                                </TableCell>
                            </TableRow>
                        ) : (
                            times.map((t, idx) => (
                                <TableRow key={idx}>
                                    <TableCell>{t.date}</TableCell>
                                    <TableCell>{t.fajr}</TableCell>
                                    <TableCell>{t.sunrise}</TableCell>
                                    <TableCell>{t.dhuhr}</TableCell>
                                    <TableCell>{t.asr}</TableCell>
                                    <TableCell>{t.maghrib}</TableCell>
                                    <TableCell>{t.isha}</TableCell>
                                </TableRow>
                            ))
                        )}
                    </TableBody>
                </Table>
            </div>
        </div>
    );
}
