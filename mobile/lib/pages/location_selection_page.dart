import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  final LocationService _locationService = LocationService();

  List<Country> _countries = [];
  List<City> _cities = [];
  List<District> _districts = [];

  Country? _selectedCountry;
  City? _selectedCity;
  District? _selectedDistrict;

  bool _isLoadingCountries = false;
  bool _isLoadingCities = false;
  bool _isLoadingDistricts = false;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries({bool refresh = false}) async {
    setState(() => _isLoadingCountries = true);
    final countries = await _locationService.getCountries(refresh: refresh);
    setState(() {
      _countries = countries;
      _isLoadingCountries = false;
    });
  }

  Future<void> _loadCities(int countryId, {bool refresh = false}) async {
    setState(() => _isLoadingCities = true);
    final cities = await _locationService.getCities(
      countryId,
      refresh: refresh,
    );
    setState(() {
      _cities = cities;
      _isLoadingCities = false;
    });
  }

  Future<void> _loadDistricts(int cityId, {bool refresh = false}) async {
    setState(() => _isLoadingDistricts = true);
    final districts = await _locationService.getDistricts(
      cityId,
      refresh: refresh,
    );
    setState(() {
      _districts = districts;
      _isLoadingDistricts = false;
    });
  }

  void _onCountrySelected(Country? country) {
    setState(() {
      _selectedCountry = country;
      _selectedCity = null;
      _selectedDistrict = null;
      _cities = [];
      _districts = [];
    });
    if (country != null) {
      _loadCities(country.id);
    }
  }

  void _onCitySelected(City? city) {
    setState(() {
      _selectedCity = city;
      _selectedDistrict = null;
      _districts = [];
    });
    if (city != null) {
      _loadDistricts(city.id);
    }
  }

  void _onDistrictSelected(District? district) {
    setState(() {
      _selectedDistrict = district;
    });
  }

  Future<void> _saveAndExit() async {
    if (_selectedDistrict != null && _selectedCity != null) {
      await _locationService.saveSelectedLocation(_selectedDistrict!, _selectedCity!.name);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Konum Seç',
          style: textTheme.titleLarge?.copyWith(
            fontFamily: 'Noto Serif',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_selectedCity != null) {
                _loadDistricts(_selectedCity!.id, refresh: true);
              } else if (_selectedCountry != null) {
                _loadCities(_selectedCountry!.id, refresh: true);
              } else {
                _loadCountries(refresh: true);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDropdown<Country>(
              label: 'Ülke Seçin',
              value: _selectedCountry,
              items: _countries,
              isLoading: _isLoadingCountries,
              onChanged: _onCountrySelected,
              getItemLabel: (c) => c.name,
            ),
            const SizedBox(height: 24),
            _buildDropdown<City>(
              label: 'Şehir Seçin',
              value: _selectedCity,
              items: _cities,
              isLoading: _isLoadingCities,
              enabled: _selectedCountry != null,
              onChanged: _onCitySelected,
              getItemLabel: (c) => c.name,
            ),
            const SizedBox(height: 24),
            _buildDropdown<District>(
              label: 'İlçe Seçin',
              value: _selectedDistrict,
              items: _districts,
              isLoading: _isLoadingDistricts,
              enabled: _selectedCity != null,
              onChanged: _onDistrictSelected,
              getItemLabel: (c) => c.name,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedDistrict != null ? _saveAndExit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Konumu Kaydet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required bool isLoading,
    bool enabled = true,
    required void Function(T?) onChanged,
    required String Function(T) getItemLabel,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: colorScheme.outline,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: enabled
                ? colorScheme.surface
                : colorScheme.surfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: Text(isLoading ? 'Yükleniyor...' : label),
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.keyboard_arrow_down),
              disabledHint: Text(
                enabled ? 'Seçiniz' : 'Önce üst seçimi yapınız',
              ),
              items: items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(getItemLabel(item)),
                );
              }).toList(),
              onChanged: enabled && !isLoading ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }
}
