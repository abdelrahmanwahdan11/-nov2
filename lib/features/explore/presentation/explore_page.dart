import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/models/enums.dart';
import '../../../core/models/event.dart';
import '../../../core/models/venue.dart';
import '../../../core/services/providers.dart';
import '../../../core/config/app_config.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  static const _initialCenter = LatLng(24.7136, 46.6753);
  final MapController _mapController = MapController();

  LatLng _center = _initialCenter;
  bool _requestingLocation = false;
  TimeWindow? _timeFilter;
  Level? _levelFilter;
  double? _maxFee;
  EventType? _typeFilter;
  StreamSubscription<Position>? _positionSub;

  @override
  void initState() {
    super.initState();
    _resolveLocation();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _resolveLocation() async {
    setState(() => _requestingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _requestingLocation = false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        setState(() => _requestingLocation = false);
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      _center = LatLng(position.latitude, position.longitude);
      _mapController.move(_center, 13);
      _positionSub = Geolocator.getPositionStream().listen((event) {
        setState(() {
          _center = LatLng(event.latitude, event.longitude);
        });
      });
    } catch (_) {
      // ignore location failures for offline mode
    } finally {
      if (mounted) {
        setState(() => _requestingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(venuesProvider);
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('استكشاف'),
        actions: [
          if (_timeFilter != null || _levelFilter != null || _maxFee != null || _typeFilter != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _timeFilter = null;
                  _levelFilter = null;
                  _maxFee = null;
                  _typeFilter = null;
                });
              },
              child: const Text('مسح'),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: venuesAsync.when(
              data: (venues) {
                return eventsAsync.when(
                  data: (events) {
                    final filteredEvents = _applyFilters(events);
                    final markers = [
                      ...venues.map((venue) => _buildVenueMarker(venue)),
                      ...filteredEvents.map((event) => _buildEventMarker(event)),
                    ];
                    return Column(
                      children: [
                        SizedBox(
                          height: 280,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _center,
                              initialZoom: 12,
                              onTap: (_, __) {},
                            ),
                            children: [
                              if (noNetworkMode)
                                const _OfflineTileLayer()
                              else
                                TileLayer(
                                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: const ['a', 'b', 'c'],
                                ),
                              MarkerLayer(markers: markers),
                            ],
                          ),
                        ),
                        if (noNetworkMode)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('وضع بلا اتصال: يتم استخدام خلفية متجهية مبسطة'),
                          ),
                        if (_requestingLocation)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        _FilterBar(
                          timeFilter: _timeFilter,
                          levelFilter: _levelFilter,
                          maxFee: _maxFee,
                          typeFilter: _typeFilter,
                          onTimeSelected: (value) => setState(() => _timeFilter = value),
                          onLevelSelected: (value) => setState(() => _levelFilter = value),
                          onFeeSelected: (value) => setState(() => _maxFee = value),
                          onTypeSelected: (value) => setState(() => _typeFilter = value),
                        ),
                        Expanded(
                          child: _ResultList(
                            venues: venues,
                            events: filteredEvents,
                            onFocus: (latLng) => _mapController.move(latLng, 14),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('خطأ: $error')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('خطأ: $error')),
            ),
          ),
        ],
      ),
    );
  }

  List<Event> _applyFilters(List<Event> events) {
    return events.where((event) {
      if (_timeFilter != null && event.timeWindow != _timeFilter) {
        return false;
      }
      if (_levelFilter != null && event.level != _levelFilter) {
        return false;
      }
      if (_maxFee != null && event.fee > _maxFee!) {
        return false;
      }
      if (_typeFilter != null && event.type != _typeFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  Marker _buildVenueMarker(Venue venue) {
    return Marker(
      point: LatLng(venue.geo.lat, venue.geo.lon),
      child: GestureDetector(
        onTap: () => _showVenueSheet(venue),
        child: const Icon(Icons.location_on, color: Colors.green, size: 32),
      ),
    );
  }

  Marker _buildEventMarker(Event event) {
    final color = switch (event.type) {
      EventType.walk => Colors.blue,
      EventType.street => Colors.orange,
      EventType.challenge => Colors.purple,
    };
    return Marker(
      point: LatLng(event.location.lat, event.location.lon),
      child: GestureDetector(
        onTap: () => _showEventSheet(event),
        child: Icon(Icons.flag, color: color, size: 30),
      ),
    );
  }

  void _showVenueSheet(Venue venue) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(venue.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(venue.address),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: venue.amenities.map((amenity) => Chip(label: Text(amenity))).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // navigation handled by GoRouter outside scope
                },
                child: const Text('احجز الآن'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEventSheet(Event event) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(event.description),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(label: Text('المستوى: ${event.level.name}')),
                  const SizedBox(width: 8),
                  Chip(label: Text('الرسوم: ${event.fee.toStringAsFixed(0)} ر.س')),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('انضم'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OfflineTileLayer extends StatelessWidget {
  const _OfflineTileLayer();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1D21), Color(0xFF0BA360)],
            ),
          ),
          child: CustomPaint(
            painter: _GridPainter(),
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1;
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.timeFilter,
    required this.levelFilter,
    required this.maxFee,
    required this.typeFilter,
    required this.onTimeSelected,
    required this.onLevelSelected,
    required this.onFeeSelected,
    required this.onTypeSelected,
  });

  final TimeWindow? timeFilter;
  final Level? levelFilter;
  final double? maxFee;
  final EventType? typeFilter;
  final ValueChanged<TimeWindow?> onTimeSelected;
  final ValueChanged<Level?> onLevelSelected;
  final ValueChanged<double?> onFeeSelected;
  final ValueChanged<EventType?> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilterChip(
            selected: timeFilter == TimeWindow.morning,
            label: const Text('الصباح'),
            onSelected: (value) => onTimeSelected(value ? TimeWindow.morning : null),
          ),
          FilterChip(
            selected: timeFilter == TimeWindow.evening,
            label: const Text('المساء'),
            onSelected: (value) => onTimeSelected(value ? TimeWindow.evening : null),
          ),
          FilterChip(
            selected: levelFilter == Level.beginner,
            label: const Text('مبتدئ'),
            onSelected: (value) => onLevelSelected(value ? Level.beginner : null),
          ),
          FilterChip(
            selected: levelFilter == Level.intermediate,
            label: const Text('متوسط'),
            onSelected: (value) => onLevelSelected(value ? Level.intermediate : null),
          ),
          FilterChip(
            selected: levelFilter == Level.advanced,
            label: const Text('متقدم'),
            onSelected: (value) => onLevelSelected(value ? Level.advanced : null),
          ),
          FilterChip(
            selected: maxFee == 0,
            label: const Text('مجاني'),
            onSelected: (value) => onFeeSelected(value ? 0 : null),
          ),
          FilterChip(
            selected: maxFee == 50,
            label: const Text('≤ 50'),
            onSelected: (value) => onFeeSelected(value ? 50 : null),
          ),
          FilterChip(
            selected: maxFee == 100,
            label: const Text('≤ 100'),
            onSelected: (value) => onFeeSelected(value ? 100 : null),
          ),
          FilterChip(
            selected: typeFilter == EventType.walk,
            label: const Text('مشي'),
            onSelected: (value) => onTypeSelected(value ? EventType.walk : null),
          ),
          FilterChip(
            selected: typeFilter == EventType.street,
            label: const Text('تمارين شارع'),
            onSelected: (value) => onTypeSelected(value ? EventType.street : null),
          ),
          FilterChip(
            selected: typeFilter == EventType.challenge,
            label: const Text('تحدي'),
            onSelected: (value) => onTypeSelected(value ? EventType.challenge : null),
          ),
        ],
      ),
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({
    required this.venues,
    required this.events,
    required this.onFocus,
  });

  final List<Venue> venues;
  final List<Event> events;
  final ValueChanged<LatLng> onFocus;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      ...venues.map((venue) => Card(
            child: ListTile(
              leading: const Icon(Icons.sports_soccer),
              title: Text(venue.name),
              subtitle: Text(venue.address),
              onTap: () => onFocus(LatLng(venue.geo.lat, venue.geo.lon)),
              trailing: Text('${venue.rating.toStringAsFixed(1)} ★'),
            ),
          )),
      ...events.map((event) => Card(
            child: ListTile(
              leading: const Icon(Icons.flag),
              title: Text(event.title),
              subtitle: Text('${event.timeWindow.name} • ${event.level.name}'),
              onTap: () => onFocus(LatLng(event.location.lat, event.location.lon)),
              trailing: Text(event.fee == 0 ? 'مجاني' : '${event.fee.toStringAsFixed(0)} ر.س'),
            ),
          )),
    ];

    if (tiles.isEmpty) {
      return const Center(child: Text('لا توجد نتائج'));
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: tiles,
    );
  }
}
