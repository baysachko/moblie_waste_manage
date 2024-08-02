import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

Future<void> updateMap(
  BuildContext context,
  double bin1Lat,
  double bin1Lng,
  double bin2Lat,
  double bin2Lng,
  Map<dynamic, dynamic> data,
  BitmapDescriptor? customIcon,
  GoogleMapController? mapController,
  Function(Set<Marker>) updateMarkers,
  Function(Set<Polyline>) updatePolylines,
) async {
  final bin1Position = LatLng(bin1Lat, bin1Lng);
  final bin2Position = LatLng(bin2Lat, bin2Lng);

  Set<Marker> markers = {
    Marker(
      markerId: MarkerId('board2'),
      position: bin1Position,
      icon: customIcon ?? BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
        title: 'Non Recyclable Bin',
        snippet:
            'Percentage: ${data['board1'] != null && data['board1']['sensor_non_recyclable'] != null ? (data['board1']['sensor_non_recyclable'] as num).toDouble() : 0}%',
      ),
    ),
    Marker(
      markerId: MarkerId('board4'),
      position: bin2Position,
      icon: customIcon ?? BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
        title: 'Recyclable Bin',
        snippet:
            'Percentage: ${data['board1'] != null && data['board1']['sensor_recyclable'] != null ? (data['board1']['sensor_recyclable'] as num).toDouble() : 0}%',
      ),
    ),
  };

  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];

  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    googleApiKey: '', // Replace with your actual API key
    request: PolylineRequest(
      origin: PointLatLng(bin1Lat, bin1Lng),
      destination: PointLatLng(bin2Lat, bin2Lng),
      mode: TravelMode.driving,
    ),
  );

  if (result.status == 'OK') {
    polylineCoordinates
        .add(LatLng(bin1Lat, bin1Lng)); // Ensure start point is included
    result.points.forEach((PointLatLng point) {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    });
    polylineCoordinates
        .add(LatLng(bin2Lat, bin2Lng)); // Ensure end point is included

    Set<Polyline> polylines = {
      Polyline(
        polylineId: PolylineId('route'),
        points: polylineCoordinates,
        color: Colors.blue,
        width: 7,
      ),
    };

    updatePolylines(polylines);
  } else {
    print(result.errorMessage);
  }

  updateMarkers(markers);

  if (mapController != null) {
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(bin1Lat < bin2Lat ? bin1Lat : bin2Lat,
              bin1Lng < bin2Lng ? bin1Lng : bin2Lng),
          northeast: LatLng(bin1Lat > bin2Lat ? bin1Lat : bin2Lat,
              bin1Lng > bin2Lng ? bin1Lng : bin2Lng),
        ),
        50,
      ),
    );
  }
}
