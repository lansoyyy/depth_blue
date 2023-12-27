import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dart_geohash/dart_geohash.dart';

import '../firebase/auth_service.dart';
import 'controller.dart';

class FloodMapScreen extends StatefulWidget {
  const FloodMapScreen({super.key});

  @override
  _FloodMapScreenState createState() => _FloodMapScreenState();
}

class _FloodMapScreenState extends State<FloodMapScreen> {
  final AuthService _authService = AuthService();
  late LocationController locationController;
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildGoogleMap(),
    );
  }

  Widget buildGoogleMap() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: const CameraPosition(
        target: LatLng(0.0, 0.0),
        zoom: 10.0,
      ),
      markers: markers,
    );
  }

  @override
  void initState() {
    super.initState();
    locationController = LocationController();
    locationController.getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      displayFloodsOnMap();
    });

    if (locationController.currentPosition != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            locationController.currentPosition!.latitude,
            locationController.currentPosition!.longitude,
          ),
          15.0,
        ),
      );
    }
  }

  Future<void> displayFloodsOnMap() async {
    try {
      User? currentUser = await _authService.getCurrentUser();

      String userUid = currentUser!.uid;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      GeoHash latitude = GeoHash.fromDecimalDegrees(4.5, 21.0);
      GeoHash longitude = GeoHash.fromDecimalDegrees(116.0, 127.0);

      QuerySnapshot querySnapshot = await firestore
          .collection('Users')
          .doc(userUid)
          .collection('flood')
          .where('latlong.latitude', isEqualTo: latitude)
          .where('latlong.longitude', isEqualTo: longitude)
          .get();

      List<Marker> newMarkers = [];

      for (var document in querySnapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        double latitude = data['latlong']['latitude'];
        double longitude = data['latlong']['longitude'];
        String waterLevel = data['waterlevel'];

        BitmapDescriptor markerIcon = getMarkerIconByWaterLevel(waterLevel);

        Marker marker = Marker(
          markerId: MarkerId(document.id),
          position: LatLng(latitude, longitude),
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: 'Water Level: $waterLevel',
          ),
        );

        newMarkers.add(marker);
      }

      setState(() {
        markers = Set.of(newMarkers);
      });

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(getBounds(newMarkers), 100.0),
        );
      }
    } catch (e) {
      print('Error fetching and displaying floods: $e');
    }
  }

  BitmapDescriptor getMarkerIconByWaterLevel(String waterLevel) {
    switch (waterLevel) {
      case 'high':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'medium':
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueYellow);
      case 'low':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  LatLngBounds getBounds(List<Marker> markers) {
    double minLat = double.infinity;
    double minLng = double.infinity;
    double maxLat = double.negativeInfinity;
    double maxLng = double.negativeInfinity;

    for (var marker in markers) {
      double lat = marker.position.latitude;
      double lng = marker.position.longitude;

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
