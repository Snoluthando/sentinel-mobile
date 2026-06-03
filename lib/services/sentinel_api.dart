import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:hello_flutter/config/api_config.dart';
import 'package:hello_flutter/models/incident.dart';

class SentinelApiException implements Exception {
  SentinelApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class SentinelApi {
  SentinelApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$kSentinelApiBaseUrl$path').replace(queryParameters: query);
  }

  Future<Position> currentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw SentinelApiException('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw SentinelApiException('Location permission is required.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<List<Incident>> fetchNearbyIncidents({
    int hours = 48,
    double? lat,
    double? lng,
    int radiusM = 10000,
  }) async {
    double useLat = lat ?? kDefaultLat;
    double useLng = lng ?? kDefaultLng;

    if (lat == null || lng == null) {
      try {
        final pos = await currentPosition();
        useLat = pos.latitude;
        useLng = pos.longitude;
      } catch (_) {
        // Fall back to default centre (matches RN when no GPS in query).
      }
    }

    final response = await _client.get(_uri('/incidents/nearby', {
      'lat': useLat.toString(),
      'lng': useLng.toString(),
      'radius_m': radiusM.toString(),
      'hours': hours.toString(),
    }));

    if (response.statusCode != 200) {
      throw SentinelApiException(
        'Failed to load incidents (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    final body = jsonDecode(response.body);
    final List<dynamic> raw;
    if (body is List) {
      raw = body;
    } else if (body is Map<String, dynamic>) {
      raw = body['data'] as List<dynamic>? ?? [];
    } else {
      raw = [];
    }

    return raw
        .whereType<Map<String, dynamic>>()
        .map(Incident.fromJson)
        .toList();
  }

  Future<void> submitIncident({
    required String category,
    required String title,
    String? description,
    required double lat,
    required double lng,
    bool anonymous = true,
  }) async {
    final response = await _client.post(
      _uri('/incidents'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'category': category,
        'title': title,
        'description': description ?? '',
        'lat': lat,
        'lng': lng,
        'anonymous': anonymous,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String message = 'Failed to submit report (${response.statusCode})';
    try {
      final err = jsonDecode(response.body);
      if (err is Map && err['error'] != null) {
        message = err['error'].toString();
      } else if (err is Map && err['message'] != null) {
        message = err['message'].toString();
      }
    } catch (_) {}

    throw SentinelApiException(message, statusCode: response.statusCode);
  }
}
