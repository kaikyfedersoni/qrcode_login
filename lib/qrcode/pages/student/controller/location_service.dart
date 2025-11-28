import 'package:geolocator/geolocator.dart';

class LocationService {
  // Coordenadas da faculdade
  static const double allowedLatitude = -23.238735019563432;
  static const double allowedLongitude = -47.05595388839692;
  static const double allowedRadiusMeters = 1000; // 1 km

  /// Verifica se o usuário está dentro da área permitida
  static Future<bool> isInsideAllowedArea() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviço de localização desativado.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização permanentemente negada.');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      allowedLatitude,
      allowedLongitude,
    );

    return distance <= allowedRadiusMeters;
  }
}
