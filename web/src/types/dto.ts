import { ContentType, Language } from "./enums";

export interface CityDto {
    sehirID: number;
    sehirAdi: string;
}

export interface CountryDto {
    ulkeID: number;
    ulkeAdi: string;
}

export interface DistrictDto {
    ilceID: number;
    ilceAdi: string;
}

export interface DailyContentDto {
    id: string;
    title: string;
    content: string;
    type: ContentType;
    date: string;
}

export interface LogDto {
    id: string;
    userId: string;
    action: string;
    description: string;
    data: string;
    ipAddress: string;
    createdAt: string;
}

export interface SettingDto {
    id: string;
    key: string;
    value: string;
    description?: string;
}

export interface SpecialDayDto {
    id: string;
    name: string;
    date: string;
    description: string;
}

export interface ExternalPrayerTimeDto {
    imsak: string;
    gunes: string;
    gunesDogus: string;
    gunesBatis: string;
    ogle: string;
    ikindi: string;
    aksam: string;
    yatsi: string;
    miladiTarihKisa: string;
    hicriTarihUzun: string;
}

export interface PrayerTimeDto {
    date: string;
    fajr: string;
    sunrise: string;
    dhuhr: string;
    asr: string;
    maghrib: string;
    sunset: string;
    isha: string;
    hijriDateLong: string;
}

export interface LoginUserResultDto {
    id: string;
    name: string;
    email: string;
    language: string;
    token: string;
}

export interface UserDto {
    id: string;
    name: string;
    email: string;
    language: string;
}
