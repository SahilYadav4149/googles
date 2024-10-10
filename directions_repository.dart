import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'directions_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  final Dio _dio;

  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': "AIzaSyCzt7OoM8ejKRWIIiFVA9jk5obI1Ny-B3s",
        },
      );

      // Check if response is successful
      if (response.statusCode == 200 && response.data != null) {
        return Directions.fromMap(response.data);
      }
    } catch (e) {
      print('Error fetching directions: $e');
    }
    return null; // Return null if an error occurred or response failed
  }
}
