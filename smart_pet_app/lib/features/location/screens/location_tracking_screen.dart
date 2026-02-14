import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/location_provider.dart';
import '../models/geofence.dart';

class LocationTrackingScreen extends ConsumerStatefulWidget {
  const LocationTrackingScreen({super.key});

  @override
  ConsumerState<LocationTrackingScreen> createState() =>
      _LocationTrackingScreenState();
}

class _LocationTrackingScreenState
    extends ConsumerState<LocationTrackingScreen> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationStream = ref.watch(locationStreamProvider);
    final geofenceState = ref.watch(geofenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Location Tracking'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh location
              ref.invalidate(currentLocationProvider);
            },
          ),
        ],
      ),
      body: locationStream.when(
        data: (location) {
          return Column(
            children: [
              // Location Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.deepPurple.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Text(
                          'Current Location',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Latitude: ${location.latitude.toStringAsFixed(6)}'),
                    Text('Longitude: ${location.longitude.toStringAsFixed(6)}'),
                    if (location.accuracy != null)
                      Text(
                        'Accuracy: ${location.accuracy!.toStringAsFixed(1)}m',
                      ),
                    if (location.speed != null)
                      Text(
                        'Speed: ${(location.speed! * 3.6).toStringAsFixed(1)} km/h',
                      ),
                    Text('Updated: ${_formatTime(location.timestamp)}'),
                  ],
                ),
              ),

              // Map View
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(location.latitude, location.longitude),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: {
                    Marker(
                      markerId: const MarkerId('pet_location'),
                      position: LatLng(location.latitude, location.longitude),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueViolet,
                      ),
                      infoWindow: InfoWindow(
                        title: 'Pet Location',
                        snippet:
                            'Last updated: ${_formatTime(location.timestamp)}',
                      ),
                    ),
                  },
                  circles: geofenceState.geofences
                      .where((fence) => fence.isActive)
                      .map(
                        (fence) => Circle(
                          circleId: CircleId(fence.id),
                          center: LatLng(
                            fence.centerLatitude,
                            fence.centerLongitude,
                          ),
                          radius: fence.radiusInMeters,
                          fillColor: Colors.blue.withValues(alpha: 0.2),
                          strokeColor: Colors.blue,
                          strokeWidth: 2,
                        ),
                      )
                      .toSet(),
                ),
              ),

              // Geofence Status
              if (geofenceState.geofences.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Geofences (${geofenceState.geofences.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...geofenceState.geofences.map((fence) {
                        final isInside = ref
                            .read(locationServiceProvider)
                            .isWithinGeofence(
                              currentLat: location.latitude,
                              currentLng: location.longitude,
                              centerLat: fence.centerLatitude,
                              centerLng: fence.centerLongitude,
                              radiusInMeters: fence.radiusInMeters,
                            );

                        return ListTile(
                          dense: true,
                          leading: Icon(
                            isInside ? Icons.check_circle : Icons.warning,
                            color: isInside ? Colors.green : Colors.red,
                          ),
                          title: Text(fence.name),
                          subtitle: Text(
                            isInside
                                ? 'Inside safe zone'
                                : '⚠️ Outside safe zone!',
                          ),
                          trailing: Switch(
                            value: fence.isActive,
                            onChanged: (value) {
                              ref
                                  .read(geofenceProvider.notifier)
                                  .toggleGeofence(fence.id);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Getting location...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(locationStreamProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add_geofence',
            onPressed: () => _showAddGeofenceDialog(context),
            child: const Icon(Icons.add_location),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'center_map',
            onPressed: () {
              locationStream.whenData((location) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(location.latitude, location.longitude),
                  ),
                );
              });
            },
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showAddGeofenceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final radiusController = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Geofence'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Geofence Name',
                hintText: 'e.g., Home, Park',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: radiusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Radius (meters)',
                hintText: '100',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Geofence will be created at current location',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a name')),
                );
                return;
              }

              final location = ref.read(locationStreamProvider).value;
              if (location != null) {
                final geofence = Geofence(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  centerLatitude: location.latitude,
                  centerLongitude: location.longitude,
                  radiusInMeters: double.tryParse(radiusController.text) ?? 100,
                );

                ref.read(geofenceProvider.notifier).addGeofence(geofence);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Geofence "${geofence.name}" added!')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
