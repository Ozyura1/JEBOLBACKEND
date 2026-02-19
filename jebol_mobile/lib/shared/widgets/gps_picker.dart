import 'package:flutter/material.dart';
import 'package:location/location.dart';

class GpsPicker extends StatefulWidget {
  final ValueChanged<LocationData> onLocationPicked;
  final LocationData? initial;

  const GpsPicker({super.key, required this.onLocationPicked, this.initial});

  @override
  State<GpsPicker> createState() => _GpsPickerState();
}

class _GpsPickerState extends State<GpsPicker> {
  final Location _location = Location();
  bool _isLoading = false;
  LocationData? _current;
  String? _error;

  @override
  void initState() {
    super.initState();
    _current = widget.initial;
  }

  Future<void> _pickLocation() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          setState(() => _error = 'GPS tidak aktif.');
          return;
        }
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) {
          setState(() => _error = 'Izin lokasi ditolak.');
          return;
        }
      }

      final locationData = await _location.getLocation();
      _current = locationData;
      widget.onLocationPicked(locationData);
    } catch (e) {
      _error = 'Gagal mengambil lokasi.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = _current?.latitude;
    final lng = _current?.longitude;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lokasi GPS', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                lat != null && lng != null
                    ? 'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}'
                    : 'Belum diambil',
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _pickLocation,
              child: Text(_isLoading ? 'Memuat...' : 'Ambil GPS'),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 6),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
      ],
    );
  }
}
