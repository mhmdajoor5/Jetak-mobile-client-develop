import 'dart:async';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../helpers/custom_trace.dart';
import '../models/Step.dart';
import '../repository/settings_repository.dart';

class MapsUtil {
  static const BASE_URL = "https://maps.googleapis.com/maps/api/directions/json?";
  static MapsUtil _instance = new MapsUtil.internal();
  MapsUtil.internal();
  factory MapsUtil() => _instance;
  final JsonDecoder _decoder = new JsonDecoder();

  Future<List<LatLng>?> get(String url) async {
    try {
      print("Making request to: ${BASE_URL + url}");
      
      final response = await http.get(
        Uri.parse(BASE_URL + url),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Request timeout', Duration(seconds: 15));
        },
      );

      String res = response.body;
      int statusCode = response.statusCode;
      
      print("API Response Status: $statusCode");
      print("API Response Body: $res");

      if (statusCode < 200 || statusCode > 400) {
        throw Exception("HTTP Error: $statusCode - $res");
      }

      List<LatLng> steps = [];
      try {
        final decodedResponse = _decoder.convert(res);
        
        // Check API response status
        if (decodedResponse["status"] != "OK") {
          String status = decodedResponse["status"] ?? "UNKNOWN_ERROR";
          String errorMessage = decodedResponse["error_message"] ?? "No error message provided";
          
          print("Google Maps API Error: $status - $errorMessage");
          
          switch (status) {
            case "ZERO_RESULTS":
              print("No route found between the specified points");
              return [];
            case "REQUEST_DENIED":
              print("API key is invalid or request was denied");
              throw Exception("API key invalid or request denied: $errorMessage");
            case "INVALID_REQUEST":
              print("Invalid request parameters");
              throw Exception("Invalid request: $errorMessage");
            case "OVER_QUERY_LIMIT":
              print("API quota exceeded");
              throw Exception("API quota exceeded: $errorMessage");
            default:
              throw Exception("API Error: $status - $errorMessage");
          }
        }

        // Check if routes exist
        if (decodedResponse["routes"] == null || 
            decodedResponse["routes"].isEmpty) {
          print("No routes found in response");
          return [];
        }

        // Check if legs exist
        if (decodedResponse["routes"][0]["legs"] == null || 
            decodedResponse["routes"][0]["legs"].isEmpty) {
          print("No legs found in route");
          return [];
        }

        // Check if steps exist
        if (decodedResponse["routes"][0]["legs"][0]["steps"] == null) {
          print("No steps found in leg");
          return [];
        }

        steps = parseSteps(decodedResponse["routes"][0]["legs"][0]["steps"]);
        print("Successfully parsed ${steps.length} steps");
        
      } catch (e) {
        print(CustomTrace(StackTrace.current, message: 'Error parsing response: $e'));
        throw Exception("Failed to parse directions response: $e");
      }
      
      return steps;
      
    } on TimeoutException catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Request timeout: $e'));
      throw Exception("Request timeout - please check your internet connection");
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Network error: $e'));
      rethrow;
    }
  }

  List<LatLng> parseSteps(final responseBody) {
    try {
      List<Step> _steps = responseBody.map<Step>((json) {
        return Step.fromJson(json);
      }).toList();
      
      List<LatLng> _latLang = _steps.map((Step step) => step.startLatLng).toList();
      return _latLang;
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error parsing steps: $e'));
      return [];
    }
  }

  Future<String?> getAddressName(LatLng? location, String apiKey) async {
    try {
      if (location == null) {
        print("Location is null for address lookup");
        return null;
      }

      var endPoint = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&language=${setting.value.mobileLanguage.value}&key=$apiKey';
      
      final response = await http.get(Uri.parse(endPoint)).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Geocoding timeout', Duration(seconds: 10));
        },
      );

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);
        if (decodedResponse["status"] == "OK" && decodedResponse["results"].isNotEmpty) {
          return decodedResponse["results"][0]["formatted_address"];
        }
      }
      
      return "Unknown Address";
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: 'Error getting address: $e'));
      return null;
    }
  }
}