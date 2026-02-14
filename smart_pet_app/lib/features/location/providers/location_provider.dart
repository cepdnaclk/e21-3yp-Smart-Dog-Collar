import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_location.dart';
import '../models/geofence.dart';
import '../services/location_service.dart';

// Provider for LocationService instance
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Provider for current location (one-time)
final currentLocationProvider = FutureProvider<PetLocation?>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  final position = await locationService.getCurrentLocation();

  if (position != null) {
    return PetLocation.fromPosition(position);
  }
  return null;
});

// Provider for location permission status
final locationPermissionProvider = FutureProvider<bool>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return await locationService.requestLocationPermission();
});

// Provider for continuous location tracking stream
final locationStreamProvider = StreamProvider<PetLocation>((ref) {
  final locationService = ref.read(locationServiceProvider);

  return locationService.getLocationStream().map((position) {
    return PetLocation.fromPosition(position);
  });
});

// Simple state class for geofences
class GeofenceState {
  final List<Geofence> geofences;

  GeofenceState({this.geofences = const []});

  GeofenceState copyWith({List<Geofence>? geofences}) {
    return GeofenceState(geofences: geofences ?? this.geofences);
  }
}

// Geofence Notifier using StateNotifier alternative
class GeofenceNotifier extends Notifier<GeofenceState> {
  @override
  GeofenceState build() {
    return GeofenceState();
  }

  // Add a new geofence
  void addGeofence(Geofence geofence) {
    state = state.copyWith(geofences: [...state.geofences, geofence]);
  }

  // Remove a geofence by ID
  void removeGeofence(String id) {
    state = state.copyWith(
      geofences: state.geofences.where((fence) => fence.id != id).toList(),
    );
  }

  // Update a geofence
  void updateGeofence(Geofence updatedGeofence) {
    state = state.copyWith(
      geofences: [
        for (final fence in state.geofences)
          if (fence.id == updatedGeofence.id) updatedGeofence else fence,
      ],
    );
  }

  // Toggle geofence active status
  void toggleGeofence(String id) {
    state = state.copyWith(
      geofences: [
        for (final fence in state.geofences)
          if (fence.id == id)
            fence.copyWith(isActive: !fence.isActive)
          else
            fence,
      ],
    );
  }

  // Check if current location is outside any active geofence
  List<Geofence> checkGeofenceBreaches(PetLocation currentLocation) {
    final locationService = ref.read(locationServiceProvider);
    List<Geofence> breachedFences = [];

    for (final fence in state.geofences) {
      if (!fence.isActive) continue;

      bool isInside = locationService.isWithinGeofence(
        currentLat: currentLocation.latitude,
        currentLng: currentLocation.longitude,
        centerLat: fence.centerLatitude,
        centerLng: fence.centerLongitude,
        radiusInMeters: fence.radiusInMeters,
      );

      if (!isInside) {
        breachedFences.add(fence);
      }
    }

    return breachedFences;
  }

  // Get all active geofences
  List<Geofence> getActiveGeofences() {
    return state.geofences.where((fence) => fence.isActive).toList();
  }

  // Clear all geofences
  void clearAll() {
    state = state.copyWith(geofences: []);
  }
}

// Provider for geofence management
final geofenceProvider = NotifierProvider<GeofenceNotifier, GeofenceState>(() {
  return GeofenceNotifier();
});

// Provider to check for geofence breaches
final geofenceBreachProvider = Provider<List<Geofence>>((ref) {
  final currentLocationAsync = ref.watch(locationStreamProvider);

  return currentLocationAsync.when(
    data: (location) {
      final notifier = ref.read(geofenceProvider.notifier);
      return notifier.checkGeofenceBreaches(location);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
