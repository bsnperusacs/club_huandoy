// 📁 Ubicación: lib/core/servicios/geocerca_service.dart

import 'package:geolocator/geolocator.dart';

class GeocercaResultado {
  final bool permitido;
  final double distanciaMetros;
  final double lat;
  final double lng;

  GeocercaResultado({
    required this.permitido,
    required this.distanciaMetros,
    required this.lat,
    required this.lng,
  });
}

class GeocercaService {
  // Radio permitido en metros
  static const double radioPermitido = 10.0;

  // ============================================================
  // VERIFICAR PERMISOS
  // ============================================================
  Future<void> _verificarPermisos() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      throw 'El servicio de ubicación está desactivado';
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        throw 'Permiso de ubicación denegado';
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      throw 'Permiso de ubicación denegado permanentemente';
    }
  }

  // ============================================================
  // VALIDAR GEOFENCE
  // ============================================================
  Future<GeocercaResultado> validarGeocerca({
    required double latCentro,
    required double lngCentro,
  }) async {
    await _verificarPermisos();

    final posicion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final distancia = Geolocator.distanceBetween(
      latCentro,
      lngCentro,
      posicion.latitude,
      posicion.longitude,
    );

    return GeocercaResultado(
      permitido: distancia <= radioPermitido,
      distanciaMetros: distancia,
      lat: posicion.latitude,
      lng: posicion.longitude,
    );
  }
}
