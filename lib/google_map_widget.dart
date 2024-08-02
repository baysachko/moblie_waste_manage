import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'map_updates.dart'; // Add this import
import 'realtime_database_service.dart';
import 'bin_percentage_widget.dart';
import 'trash_counter_widget.dart';
import 'your_data_model.dart';

class GoogleMapWidget extends StatefulWidget {
  final RealtimeDatabaseService realtimeDatabaseService;

  const GoogleMapWidget({super.key, required this.realtimeDatabaseService});

  @override
  _GoogleMapWidgetState createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? _mapController;
  final LatLng _initialPosition = const LatLng(11.549998, 104.906794);
  LatLng? _bin1Position;
  LatLng? _bin2Position;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  double? _previousLatitudeBin1;
  double? _previousLongitudeBin1;
  double? _previousLatitudeBin2;
  double? _previousLongitudeBin2;
  BitmapDescriptor? customIcon;
  YourDataModel? selectedBin;
  bool dataUpdated = false;

  void _loadCustomIcon() async {
    // ignore: deprecated_member_use
    customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(0, 0)),
      'assets/bin.png', // Path to your custom icon
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder<DatabaseEvent>(
            stream: widget.realtimeDatabaseService.getDataStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                if (kDebugMode) {
                  print("Data received: ${snapshot.data!.snapshot.value}");
                }
                final data =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final bin1Latitude =
                    data['board2'] != null && data['board2']['latitude'] != null
                        ? (data['board2']['latitude'] as num).toDouble()
                        : 0.0;
                final bin1Longitude = data['board2'] != null &&
                        data['board2']['longitude'] != null
                    ? (data['board2']['longitude'] as num).toDouble()
                    : 0.0;
                final bin2Latitude =
                    data['board4'] != null && data['board4']['latitude'] != null
                        ? (data['board4']['latitude'] as num).toDouble()
                        : 0.0;
                final bin2Longitude = data['board4'] != null &&
                        data['board4']['longitude'] != null
                    ? (data['board4']['longitude'] as num).toDouble()
                    : 0.0;

                if (bin1Latitude != _previousLatitudeBin1 ||
                    bin1Longitude != _previousLongitudeBin1 ||
                    bin2Latitude != _previousLatitudeBin2 ||
                    bin2Longitude != _previousLongitudeBin2) {
                  _previousLatitudeBin1 = bin1Latitude;
                  _previousLongitudeBin1 = bin1Longitude;
                  _previousLatitudeBin2 = bin2Latitude;
                  _previousLongitudeBin2 = bin2Longitude;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    updateMap(
                        context,
                        bin1Latitude,
                        bin1Longitude,
                        bin2Latitude,
                        bin2Longitude,
                        data,
                        customIcon,
                        _mapController, (newMarkers) {
                      setState(() {
                        _markers = newMarkers;
                      });
                    }, (newPolylines) {
                      setState(() {
                        _polylines = newPolylines;
                      });
                    });
                  });
                }
              } else {
                if (kDebugMode) {
                  print("No data available or error fetching data");
                }
              }

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 13.0,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  if (_bin1Position != null && _bin2Position != null) {
                    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
                      LatLngBounds(
                        southwest: LatLng(
                            _bin1Position!.latitude < _bin2Position!.latitude
                                ? _bin1Position!.latitude
                                : _bin2Position!.latitude,
                            _bin1Position!.longitude < _bin2Position!.longitude
                                ? _bin1Position!.longitude
                                : _bin2Position!.longitude),
                        northeast: LatLng(
                            _bin1Position!.latitude > _bin2Position!.latitude
                                ? _bin1Position!.latitude
                                : _bin2Position!.latitude,
                            _bin1Position!.longitude > _bin2Position!.longitude
                                ? _bin1Position!.longitude
                                : _bin2Position!.longitude),
                      ),
                      50,
                    ));
                  }
                },
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                ].toSet(),
              );
            },
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 1,
            builder: (BuildContext context, ScrollController scrollController) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: ListView(
                      padding: EdgeInsets.all(10),
                      controller: scrollController,
                      children: <Widget>[
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            margin: EdgeInsets.only(top: 0, bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(12.0),
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              'Waste Bin Details',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontFamily: 'San Francisco',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        BinPercentageWidget(
                          realtimeDatabaseService:
                              widget.realtimeDatabaseService,
                        ),
                        TrashCounterWidget(
                          realtimeDatabaseService:
                              widget.realtimeDatabaseService,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
